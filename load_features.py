import timeit
import os
from sqlalchemy import create_engine
import pandas as pd
import numpy as np

start = timeit.default_timer()

sql = """
    SELECT * FROM sb_marketing.sl_lookalike_features_final
    WHERE category = '$category$'
    ORDER BY member_srl LIMIT 1000;"""

cwd = os.getcwd()
cwd = os.path.join(cwd, 'data')

df_feature_code = pd.read_csv(os.path.join(cwd, "feature_code.csv"))
df_feature_code['code'] = [str(code).zfill(3) for code in df_feature_code.code]
df_feature_code = df_feature_code.replace(np.nan, "null")

complete = True

cat2code = {}
for idx, row in df_feature_code.iterrows():
    cat2code[row["category"]] = row["code"]

categories = list(df_feature_code.category.drop_duplicates().values)

engine = create_engine('postgresql://user_marketing:ONDB=e62LvaQ@dw-sandbox-3.coupang.net:5439/sandbox')

for category in categories:
    path = os.path.join(cwd, "%s_%s.csv"%(cat2code[category], category.replace("/", " ")))
    if os.path.isfile(path) == False:
        complete = False
        print("Retrieving progress %.2f%%: category %s%s                  "
          %(100 * (categories.index(category) + 1) / len(categories), category, "." * (categories.index(category) % 3)), end = "\r")

        sql_ = sql.replace('$category$', category)
        df = pd.read_sql_query(sql_, engine)

        df.to_csv(path, index = False)
        
if complete is True:
    print("All feature files exist. No need to download.")
else:
    stop = timeit.default_timer()
    print("Features downloaded: %i m %.3f s                        "
    	%((stop - start) // 60, (stop - start) % 60))