import os
from sqlalchemy import create_engine
import pandas as pd
import numpy as np
import Lookalike

sample_size = 10000
sql = "SELECT member_srl FROM sb_marketing.sl_lookalike_active_customers ORDER BY RANDOM() LIMIT %i;"%sample_size

engine = create_engine('postgresql://user_marketing:ONDB=e62LvaQ@dw-sandbox-3.coupang.net:5439/sandbox')

df = pd.read_sql_query(sql, engine)

srl_path = os.path.join("data", "population_sample_srls.csv")
if os.path.isfile(srl_path):
    print("Population sample member_srl file exists: %s"%srl_path)
else:
    df.to_csv(srl_path, index = False)
    print("Population sample member_srl file saved: %s"%srl_path)

feature_path = os.path.join("data", "population_sample_features.csv")

if os.path.isfile(feature_path):
    print("Population sample feature file exists: %s"%feature_path)
else:
    df_source_srls = pd.read_csv(srl_path)
    source_srls = df_source_srls.sort_values("member_srl").member_srl.values
    model = Lookalike.Model(source_srls, "", verbose = False)
    model.loadSourceAudienceFeatures(path = os.path.join("data", "population_sample_features.csv"))
    print("\nPopulation sample feature file saved: %s"%feature_path)