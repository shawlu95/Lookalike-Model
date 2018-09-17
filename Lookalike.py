from sqlalchemy import create_engine
import timeit
import pandas as pd
import os
import numpy as np
import scipy
from scipy import stats
import matplotlib.pyplot as plt
import math

key_srl = "member_srl"
critical_err = """
Critical Error:
No feature observes a significant divergence from population. Lookalike model cannot proceed.
Rerun selectTopFeatures() with lower js_div threshold or rebuild source audience with higher signal-noise ratio.
                """

class Model():
    """
    Attributes:
    """
    output_dir = None
    persona = None
    source_srls = None
    lookalike_srls = None
    
    source_features = None
    source_top_features = None
    lookalike_features = None
    population_features = None
    population_sample_features = None
    
    path = None
    features = None
    top_features = None
    categories = None
    cat2code = None
    
    # full feature set
    # symbols = ["cto", "ctq", "ctv", "cts", 
    #            "dpo", "dpq", "dsl", "gpo", 
    #            "gpq", "gpd", "vpo", "vpq", 
    #            "vsl", "spo", "spq", "ssl", "aas"]

    # current (limited) feature set
    symbols = ["cto", "ctq", 
               "dpo", "dpq", "dsl", "gpo", 
               "gpq", "gpd", 
               "aas"]
    
    engine = create_engine('postgresql://user_marketing:ONDB=e62LvaQ@dw-sandbox-3.coupang.net:5439/sandbox')
        
    def __init__(self, source_srls, output_dir, runtime = False, verbose = True):
        """
        Initialize:
        """
        if runtime is True:
            start = timeit.default_timer()
        
        self.source_srls = source_srls
        self.loadFeaturesCode()

        self.output_dir = output_dir
        self.path = os.path.join("output", output_dir)
        if os.path.isdir(self.path) is False:
            os.mkdir(self.path) 
        
        # issue warning if feature files are not fully downloaded
        for category in self.categories:
            path = os.path.join("data", "%s_%s.csv"%(self.cat2code[category], category.replace("/", " ")))
            if os.path.isfile(path) == False and verbose == True:
                print("Warning: feature files are not fully downloaded. Refer to starter.ipynb to download all features.")
                break
        
        if verbose is True:
            if len(source_srls) > 50000:
                print("Warning: source audience may be too large: %i"%len(source_srls))
            elif len(source_srls) < 5000:
                print("Warning: source audience may be too small: %i"%len(source_srls))
            else:
                print("Source audience size: %i"%len(source_srls))

        # issue warning if population random sample has not been downloaded
        pop_sample_feature_path = os.path.join("data", "population_sample_features.csv")
        if os.path.isfile(pop_sample_feature_path) is False:
            if verbose is True: print("Warning: population sample features have not been downloaded. \nRefer to starter.ipynb to download population sample.")
        else:
            if verbose is True: print("Population sample features have been downloaded. Read file: %s"%pop_sample_feature_path)
            self.population_sample_features = pd.read_csv(os.path.join("data", "population_sample_features.csv"))

        if runtime is True:
            stop = timeit.default_timer()
            print("Features dataframe loaded: %i m %.3f s                        "
                  %((stop - start) // 60, (stop - start) % 60))
            
    def loadFeaturesCode(self):
        """
        Help:
        """
        df_features = pd.read_csv(os.path.join("data", "feature_code.csv"))
        df_features['code'] = [str(code).zfill(3) for code in df_features.code]
        df_features = df_features.set_index("feature")

        self.cat2code = {}
        self.code2cat = {}

        df_features = df_features.replace(np.nan, "null")
        for idx, row in df_features.iterrows():
            self.cat2code[row["category"]] = row["code"]
            self.code2cat[row["code"]] = row["category"]
        
        self.features = df_features
        self.categories = list(df_features.category.drop_duplicates().values)

    def computeWeight(self, population, sample, feature, min_bin_size = 8, min_bins = 16):
        def jsdiv(P, Q):
            """Compute the Jensen-Shannon divergence between two probability distributions.
            Input
            -----
            P, Q : np array
                Probability distributions of equal length that sum to 1

            """
            def kldiv(A, B):
                # return sum(v * np.log2(v / u) for v, u in zip(A, B) if u != 0)
                # return np.sum([v * np.log2(v/u) for v, u in zip(A, B) if not np.isnan(u)])
                return np.sum([v for v in A * np.log2(A/B) if not np.isnan(v)])
            M = 0.5 * (P + Q)
            return 0.5 * (kldiv(P, M) + kldiv(Q, M))
    
        # ensure each bin has at least min_bin_size datapoints
        valid_sample = min(len(sample[feature].dropna()), len(population[feature].dropna()))
        bins = valid_sample // min_bin_size
        if bins > min_bins:
            # warning: density is not normalized
            # manually normalize it to sum to 1
            pmf1_raw, pmf1_bin = np.histogram(population[feature].dropna(), density=True)
            pmf1 = pmf1_raw / sum(pmf1_raw)

            # warning: two histograms must set the same bins
            pmf2_raw, pmf2_bin = np.histogram(sample[feature].dropna(), pmf1_bin, density=True)
            pmf2 = pmf2_raw / sum(pmf2_raw)
            return jsdiv(pmf1, pmf2)
        return None
        
    def loadSourceAudienceFeatures(self, runtime = False, path = None, verbose = True, overwrite = False):
        if runtime is True:
            start = timeit.default_timer()
        if path is None:
            path = os.path.join(self.path, "src_features.csv")
        if os.path.isfile(path) and overwrite is False:
            if verbose is True: 
                print("Source features have been downloaded. Read file: %s"%path)
                print("To overwrite existing file, pass argument overwrite = True")
            self.source_features = pd.read_csv(path, index_col = key_srl)

            if runtime is True:
                stop = timeit.default_timer()
                print("Features dataframe loaded: %i m %.3f s                        "
                      %((stop - start) // 60, (stop - start) % 60))
            return
        
        pop_feature_path = os.path.join(self.path, "pop_features.csv")
        if os.path.isfile(pop_feature_path):
            os.remove(pop_feature_path)

        df_features = pd.DataFrame(columns=self.features.index, index=self.source_srls)
        df_features.index.name = key_srl
        
        srl_strs = [str(srl) for srl in self.source_srls]
        srls_str = "(%s)"%(", ".join(srl_strs))
            
        def loadCategorySpecificFeatures(df_features):
            sql = """   SELECT DISTINCT * 
                        FROM sb_marketing.sl_lookalike_features_final
                        WHERE member_srl IN $srl_samps$
                            AND category = $category$
                        ORDER BY member_srl;
                        """
            sql = sql.replace("\n", " ").replace("\t", " ")
            sql = sql.replace("$srl_samps$", srls_str)
            for category in self.categories:
                if verbose is True: 
                    print("Downloading features from Redshift. Progress %.2f %%. Category: %s%s                  "
                          %(100 * (self.categories.index(category) + 1) / len(self.categories), category,
                            "." * (self.categories.index(category) % 3)), end = "\r")
                sql_ = sql.replace("$category$", "'%s'"%category)
                df_1c = pd.read_sql_query(sql_, self.engine)
                df_1c = df_1c.set_index(key_srl)
                for sym in self.symbols:
                    feature = sym + self.cat2code[category]
                    df_features[feature] = df_1c[sym]
        loadCategorySpecificFeatures(df_features)
        
        def loadAccountSpecificFeatures(df_features):
            sql = """   SELECT DISTINCT member_srl, age, sex, aay
                        FROM sb_marketing.sl_lookalike_features_final
                        WHERE member_srl IN $srl_samps$
                        ORDER BY member_srl;
                        """
            sql = sql.replace("\n", " ").replace("\t", " ")
            sql_ = sql.replace("$srl_samps$", srls_str)
            df_ = pd.read_sql_query(sql_, self.engine)
            df_ = df_.set_index(key_srl)
            df_ = df_.drop_duplicates()
            for category in ["age", "sex", "aay"]:
                df_features[category + "000"] = df_[category]
        loadAccountSpecificFeatures(df_features)
        
        df_features.to_csv(path)
        self.source_features = df_features
        
        if runtime is True:
            stop = timeit.default_timer()
            print("Features dataframe loaded: %i m %.3f s                        "
                  %((stop - start) // 60, (stop - start) % 60))
    
    def selectTopFeatures(self, max_features = 20, threshold = 0.05, min_bin_size = 8, min_bins = 16, runtime = False, focus = 1, verbose = True):
        if runtime is True:
            start = timeit.default_timer()
        
        self.loadFeaturesCode()
        weights = pd.Series(name='weight', index=self.features.index)
        for sym in self.symbols:
            for code in self.cat2code.values():
                w = self.computeWeight(self.population_sample_features, self.source_features, sym + code, min_bin_size, min_bins)
                if w:
                    weights[sym + code] = w

        for sym in ["age", "sex", "aay"]:
            w = self.computeWeight(self.population_sample_features, self.source_features, sym + "000", min_bin_size=64)
            if w:
                weights[sym + "000"] = w
        if verbose is True: 
            print("Number of valid candidate features (non-zero weights): %i"%len(weights.dropna()))
        if len(weights.dropna()) < 100 and verbose == True:
            print("Warning: not enough candidate features were found. Consider increasing source audience size.")

        self.features["js_div"] = weights

        top_features = self.features.dropna(subset=["js_div"]).sort_values("js_div")[::-1].head(max_features)
        top_features = top_features[top_features.js_div > threshold]

        if len(top_features) == 0:
            print(critical_err)
        else:
            top_features["weight"] = top_features.js_div ** focus / np.sum(top_features.js_div ** focus)
            top_features.to_csv(os.path.join(self.path, "top_features.csv"))
            self.top_features = top_features
            self.source_top_features = self.source_features[top_features.index]
            
            # pop_feature_path = os.path.join(self.path, "pop_features.csv")
            # if os.path.isfile(pop_feature_path) and verbose == True:
            #     print("Population features already exists. Read file: %s"%pop_feature_path)
            
            if runtime is True:
                stop = timeit.default_timer()
                print("Features dataframe loaded: %i m %.3f s                        "
                      %((stop - start) // 60, (stop - start) % 60))
        
    def generateLookalikeAudience(self, m, reuse = False, runtime = False, verbose = True):
        if self.top_features is None:
            print(critical_err)
            return

        if runtime is True:
            start = timeit.default_timer()

        df_popl_features = None
        pop_feature_path = os.path.join(self.path, "pop_features.csv")
        if reuse is True and os.path.isfile(pop_feature_path):
            if verbose is True: print("Population features have been saved for top features. Read file: %s."%pop_feature_path)
            df_popl_features = pd.read_csv(pop_feature_path, index_col=key_srl)
        else:
            if verbose is True: print("Joining population features for selected feature subset.")
            i = 1
            for idx, row in self.top_features.iterrows():
                if verbose is True: print("Joining feature progress %.2f %%: %s %s %s                  "
                          %(100 * i / len(self.top_features), idx, row.category, "." * (i % 3)), end = "\r")

                if row.sym in ["age", "sex", "aay"]:
                    fname = "105_all.csv"
                else:
                    fname = "%s_%s.csv"%(row.code, str(row.category).replace("/", " "))

                df = pd.read_csv(os.path.join("data", fname), index_col = key_srl, usecols = [key_srl, row.sym])
                df = df.rename(index=str, columns={row.sym : row.sym + row.code})

                if df_popl_features is None:
                    df_popl_features = df
                else:
                    df_popl_features = df_popl_features.merge(df, on = key_srl, how = 'outer')
                    df_popl_features = df_popl_features.drop_duplicates()
                i += 1

        df_popl_features = df_popl_features.fillna(0)
        df_popl_features.to_csv(pop_feature_path, index = key_srl)
        self.population_features = df_popl_features
        
        avg = df_popl_features.mean()
        sig = df_popl_features.std()
        
        df_popl_features_nrm = (df_popl_features - avg) / sig
        df_popl_features_wgt = df_popl_features_nrm * self.top_features.weight
        
        persona = pd.DataFrame(self.source_top_features.mean())
        df = pd.DataFrame(columns=["feature", "category", "value"])
        for code in persona.index:
            df = df.append({
                "feature" : code,
                "category" : self.code2cat[code[-3:]],
                "value" : persona.loc[code].values[0]
            }, ignore_index = True)
        df = df.set_index("feature")
        if verbose is True: print("\nSource audience Persona:\n", df)
        if verbose is True: print("\nTop features, Jensen-Shannon divergence, and weights:\n", self.top_features)
        self.persona = persona.T

        df_persona_nrm = (self.persona - avg) / sig
        df_persona_wgt = df_persona_nrm * self.top_features.weight
        
        ranking = scipy.spatial.distance.cdist(df_persona_wgt, 
                                               df_popl_features_wgt.iloc[:,:], 
                                               metric="euclidean")

        scores = pd.DataFrame({key_srl : df_popl_features_wgt.index, "dist": ranking[0]})
        scores = scores.set_index(key_srl)
        scores = scores.sort_values(by=['dist'])
        llk_rank_path = os.path.join(self.path, "llk_ranking.csv")
        scores.to_csv(llk_rank_path)
        
        top_m = scores.index[:m]
        self.lookalike_srls = scores[:m] 
        self.lookalike_features = df_popl_features.loc[top_m]

        llk_feat_path = os.path.join(self.path, "llk_features.csv")
        self.lookalike_features.to_csv(llk_feat_path)
        if verbose is True: 
            print("""
Lookalike audience (size %i) has been generated.
Lookalike audienceRanking saved at: %s
Lookalike audience features saved at: %s\n"""%(m, llk_rank_path, llk_feat_path))
        
        if runtime is True:
            stop = timeit.default_timer()
            print("runtime: %i m %.3f s                        "
                %((stop - start) // 60, (stop - start) % 60))
    
    def plotTopFeatures(self, figsize = None, runtime = False, verbose = False):
        if self.top_features is None:
            print(critical_err)
            return

        if runtime is True:
            start = timeit.default_timer()

        i = 1
        
        if figsize is None:
            ncols = 3
            nrows = math.ceil(len(self.top_features) / 3)
            figsize = (20 , 4 * nrows)
        plt.figure(figsize = figsize)

        for cat in self.top_features.index:

            ax = plt.subplot(len(self.top_features) // 3 + 1, 3, i)

            bins = min(30, len(self.source_top_features[cat].dropna()) // 10)
            if bins < 5:
                if verbose is True: print("Not enough sample: valid data point: %i"%len(self.source_top_features[cat].dropna()))
                continue 

            pmf1_bin = ax.hist(self.population_sample_features[cat].dropna(), bins, alpha=0.5, density=True)
            ax.hist(self.source_top_features[cat].dropna(), pmf1_bin[1], alpha=0.5, density=True)

            ax.hist(self.lookalike_features[cat].dropna(), pmf1_bin[1], alpha=0.5, density=True)

            plt.legend(["Population", "Source", "Lookalike"])
            plt.xlabel("%s - %s (w = %.4f)"%(self.top_features.loc[cat].sym, 
                                         self.code2cat[self.top_features.loc[cat].code], 
                                         self.top_features.loc[cat].weight))

            i += 1
        plt.tight_layout()

        path = os.path.join(self.path, "lookalike.png")
        plt.savefig(path)
        if verbose is True: print("Figure saved: %s"%path)

        if runtime is True:
            stop = timeit.default_timer()
            print("runtime: %i m %.3f s                        "
                %((stop - start) // 60, (stop - start) % 60))