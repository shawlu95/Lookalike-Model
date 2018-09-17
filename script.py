import os
import sys
import timeit
import Lookalike
import pandas as pd

# input arguments
input_file_name = sys.argv[1]
output_dir_name = sys.argv[2]
max_features = int(sys.argv[3])
threshold = float(sys.argv[4])
lookalike_audience_size = int(sys.argv[5])

start = timeit.default_timer()

# main code
df_source_srls = pd.read_csv(os.path.join("input", input_file_name))
source_srls = df_source_srls.sort_values("member_srl").member_srl.values
model = Lookalike.Model(source_srls, output_dir_name)
model.loadSourceAudienceFeatures()
model.selectTopFeatures(max_features = max_features, threshold = threshold)
model.generateLookalikeAudience(m = lookalike_audience_size)
model.plotTopFeatures()

stop = timeit.default_timer()
print("runtime: %i m %.3f s                        \n"
    %((stop - start) // 60, (stop - start) % 60))