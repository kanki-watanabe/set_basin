library(dplyr)
library(readr)
#####data preprocessing######

test_data <- read.csv("rawcsv/test_data.csv",fileEncoding = "Shift-JIS")
load("D:/watanabe/累積人口/0530/R/upstream_edges_5000_Rdata.RData")

####calculate weighted average###########

buffer <- c(1100,1200,1300,1400,1600,1700,1800,1900)

for(var in buffer){
  
  subbasin <- read.csv(paste0("rawcsv/sub_basin_result_with_distance",var,".csv"))
  
  # 結果を格納するリストを初期化
  {
    all_results <- list()
    
    for (i in 1:length(unique(subbasin$basin_name))) {
      
      lowinsub <-  subbasin %>% 
        filter(basin_name == i) %>% 
        select(sub_basin_id) %>% 
        unique() %>% 
        nrow()
      
      for(n in 1:lowinsub){
        sub_id <- subbasin %>% 
          filter(basin_name == i) %>% 
          select(sub_basin_id) %>% 
          unique() %>% 
          slice(n) %>% 
          pull(sub_basin_id)
        
        # 一致する行の pipeID と distance_from_start 列を抽出
        result <- subbasin %>%
          filter(sub_basin_id == sub_id) %>%
          select(pipeID, distance_from_start)
        
        # `pipeIDs`と`test_data`を結合
        detailed_result <- test_data %>%
          filter(pipeID %in% result$pipeID) %>%
          select(pipeID, slope, Cumulative_area,Shape_length) %>%
          left_join(result, by = "pipeID") # distance_from_start列を結合
        
        # distance_from_start = 0 の場合に Shape_length の値を利用
        detailed_result <- detailed_result %>%
          mutate(inverse_distance = ifelse(distance_from_start == 0, 
                                           1 / min(detailed_result$distance_from_start[detailed_result$distance_from_start != 0], na.rm = TRUE), 
                                           1 / distance_from_start))
        
        # slope の逆距離加重平均（値が0以上120以下のものに限定）
        slope_weighted_avg <- detailed_result %>%
          filter(!is.na(slope) & !is.na(inverse_distance), slope >= 0, slope <= 120) %>%
          summarise(weighted_avg = sum(slope * inverse_distance, na.rm = TRUE) / 
                      sum(inverse_distance, na.rm = TRUE)) %>%
          pull(weighted_avg)
        
        # Cumulative_area の逆距離加重平均
        cumulative_area_weighted_avg <- detailed_result %>%
          filter(!is.na(Cumulative_area) & !is.na(inverse_distance)) %>%
          summarise(weighted_avg = sum(Cumulative_area * inverse_distance, na.rm = TRUE) / 
                      sum(inverse_distance, na.rm = TRUE)) %>%
          pull(weighted_avg)
        
        # 計算結果をデータフレームに格納
        avg_result <- data.frame(
          sub_basin_id = sub_id,
          slope_weighted_avg = slope_weighted_avg,
          cumulative_area_weighted_avg = cumulative_area_weighted_avg)
        
        all_results <- rbind(all_results,avg_result)
        
      }
      cat(sprintf("basin %d/%d finished \n",i,length(unique(subbasin$basin_name))))
    }
    head(all_results)
  }
  write.csv(all_results,paste0("weighted_average_",var,".csv"))
}

