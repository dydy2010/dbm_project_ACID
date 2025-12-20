
import json

input_path = 'data/result data/geojson/data/stzh.adm_statistische_quartiere_map.json'
output_path = 'data/result data/geojson/data/quarters_for_mongodb.jsonl'

try:
    with open(input_path, 'r') as f:
        data = json.load(f)
    
    if 'features' not in data:
        print("Error: No 'features' key found in GeoJSON.")
    else:
        features = data['features']
        print(f"Found {len(features)} quarters.")
        
        with open(output_path, 'w') as f_out:
            for feature in features:
                # Optional: Maintain the CRS info in each document if needed, 
                # but standard GeoJSON features are self-contained.
                json.dump(feature, f_out)
                f_out.write('\n')
        
        print(f"Successfully created '{output_path}' ready for MongoDB import.")

except Exception as e:
    print(f"An error occurred: {e}")
