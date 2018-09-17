from sqlalchemy import create_engine
import pandas as pd
import os
import timeit

start = timeit.default_timer()

path = os.path.join("data", "feature_code.csv")

if os.path.isfile(path):
    print("Feature codes file exists: %s. No need to download."%path)
else:
    print("Load categories from Redshift talble: sb_marketing.sl_lookalike_features_final")

    engine = create_engine('postgresql://user_marketing:ONDB=e62LvaQ@dw-sandbox-3.coupang.net:5439/sandbox')
    sql = """
            SELECT 
                DISTINCT category
                ,DENSE_RANK() OVER(ORDER BY category) AS rnk
            FROM sb_marketing.sl_lookalike_features_final
            ORDER BY category;
            """
    df = pd.read_sql_query(sql, engine)
    print("%i product categories were found."%len(df))

    df['code'] = [str(rnk).zfill(3) for rnk in df.rnk]
    df = df.set_index('code')
    df = df.drop(['rnk'], axis = 1)

    feature_syms = ["cto", "ctq", "ctv", "cts", 
                    "dpo", "dpq", "dsl", 
                    "gpo", "gpq", "gpd", 
                    "vpo", "vpq", "vsl", 
                    "spo", "spq", "ssl",
                    "aas", "age", "sex", "aay"]

    df_full = pd.DataFrame(columns=["feature", "sym", "code", "category"])

    default = '000'
    for sym in ["age", "sex", "aay"]:
        df_full = df_full.append(
                    {"feature" : sym + default,
                     "sym" : sym,
                     "code" : default,
                     "category" : "null"
                    }, ignore_index = True
                )
        
    for sym in feature_syms:
        if sym not in ["age", "sex", "aay"]:
            for code in df.index:
                df_full = df_full.append(
                    {"feature" : sym + code,
                     "sym" : sym,
                     "code" : code,
                     "category" : df.loc[code].values[0]
                    }, ignore_index = True
                )

    path = os.path.join("data", "feature_code.csv")
    df_full.to_csv(path, index_label = "idx")
    print("%i feature coding saved: %s"%(len(df_full), path))

    stop = timeit.default_timer()
    print("Feature codes downloaded: %i m %.3f s                        "
    	%((stop - start) // 60, (stop - start) % 60))