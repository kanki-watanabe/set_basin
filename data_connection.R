library(dplyr)

# 1. 横向きに結合する関数
combine_selected_data <- function(distances) {
  # 各distanceに対してデータを処理し、リストに格納
  data_list <- lapply(distances, process_subbasin_data)
  
  # 横向きに結合
  combined_data <- Reduce(function(x, y) merge(x, y, by = "pipeID", all.x = TRUE), data_list)
  
  return(combined_data)
}

# 2. データ処理関数 (前回作成したもの)
process_subbasin_data <- function(distance) {
  # ファイル名を動的に設定
  subbasin_file <- sprintf("rawcsv/sub_basin_result_with_distance%d.csv", distance)
  weighted_average_file <- sprintf("weighted_average_%d.csv", distance)
  
  # ファイルを読み込む
  subbasin_set <- read.csv(subbasin_file)
  weighted_average <- read.csv(weighted_average_file)
  
  # 重複を削除（pipeIDで重複を削除）
  subbasin_set <- subbasin_set %>% distinct(pipeID, .keep_all = TRUE)
  weighted_average <- weighted_average %>% distinct(sub_basin_id, .keep_all = TRUE)
  
  # "sub_basin_id"列をキーにleft_joinで結合
  merged_data <- left_join(subbasin_set, weighted_average, by = "sub_basin_id")
  
  # 指定した列だけを選択
  selected_data <- merged_data[, c("pipeID", "sub_basin_id", "slope_weighted_avg", "cumulative_area_weighted_avg")]
  
  # 列名を動的に設定
  names(selected_data) <- c("pipeID", 
                            sprintf("sub_basin_%d",distance), 
                            sprintf("slope_%d", distance), 
                            sprintf("cumulative_area_%d", distance))
  
  return(selected_data)
}

# 使用例: 距離100, 200, 300のデータを処理して横向きに結合
distances <-  c(1100,1200,1300,1400,1600,1700,1800,1900)
combined_result <- combine_selected_data(distances)

write.csv(combined_result,"combined_result3.csv")

# 結果を確認
str(combined_result)

combined_result[is.na(combined_result)] <- -9999

write.csv(combined_result,"combined_result_numeric3.csv")
