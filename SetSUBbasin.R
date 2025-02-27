library(readr)
library(dplyr)

# Data setting #######
test_data <- read.csv("rawcsv/test_data.csv",fileEncoding = "Shift-JIS")
distance_mat <-  read.csv("rawcsv/distance_matrics.csv",fileEncoding = "Shift-JIS")
distance_mat$NodeID[is.na(distance_mat$NodeID)] <- "JQE7108046"

load("upstream_edges_5000_Rdata.RData")

start_nodes <- read.csv("rawcsv/100point_2.csv", header = TRUE, col.names = c("NodeID") ,fileEncoding = 'UTF-8', sep = ",", stringsAsFactors = FALSE)
start_nodes[1,1] <- "JQD0879001"
start_nodes[1809,1] <- "JQD0879002"

# Main function ######

set_sub_basin <- function(id,test_data, upstream_edges_result, start_nodes, distance_mat, max_length){
  
  # Set pool
  pool <- as.data.frame(upstream_edges_result[[id]])
  colnames(pool) <- "pipeID"
  pool$basin_name <- id
  pool$sub_basin_name <- ""
  pool$source_node <- ""
  pool$new_sub_basin <- ""
  pool$distance_from_start <- NA
  
  subset_num <- 1
  start_node <- test_data[test_data$pipeID == upstream_edges_result[[id]][1], "downID"]
  start_pipe <- test_data[test_data$downID == start_node, "pipeID"]
  
  # Processed pipe list
  processed_pipes <- character(0)
  
  while(length(pool$sub_basin_name[pool$sub_basin_name == ""]) >0 ){
    cat(sprintf("basin : %d subset : %d %d \n", id, subset_num,length(pool$sub_basin_name[pool$sub_basin_name == ""])))
    # Initial setting
    sub_basin <- character(0)
    end_pipes <- character(0)
    stack <- character(0)
    
    stack <- start_pipe[1]
    
    # Main loop
    while(length(stack) >0){
      
      pipe_id <- stack[1]
      
      stack <- stack[-1]
      
      processed_pipes <- c(processed_pipes, pipe_id)
      
      
      if (subset_num <= length(test_data[test_data$downID == start_node, "pipeID"])) {
        distance <- distance_mat %>%
          filter(PipeID == pipe_id & NodeID == start_node) %>%
          select(Distance) %>%
          as.numeric()
      } else {
        distance <- distance_mat %>%
          filter(PipeID == pipe_id & NodeID == start_node) %>%
          select(Distance) %>%
          as.numeric() - distance_mat %>%
          filter(PipeID == start_pipe[1] & NodeID == start_node) %>%
          select(Distance) %>%
          as.numeric()
      }
      
      if (length(distance) == 0 || is.na(distance)) {
        next
      }
      
      distance <- distance[1]  # Retrieve a single value
      
      if(distance < max_length){
        sub_basin <- c(sub_basin, pipe_id)
        pool$distance_from_start[pool$pipeID == pipe_id] <- distance  # Record distance
        next_node <- test_data[test_data$pipeID == pipe_id, "upMH"]
        next_pipe <- test_data[test_data$downID == next_node, "pipeID"]
        next_pipe <- next_pipe[!(next_pipe %in% processed_pipes)]
        stack <- c(stack,next_pipe)
      }
      if(distance >= max_length){
        end_pipes <- c(end_pipes, pipe_id)
      }
      
      cat(sprintf("basin : %d subset : %s pipeID : %s startID : %s distance: %f stack: %d \n",id, subset_num, pipe_id, start_pipe[1], distance, length(stack)))
    }
    
    pool$sub_basin_name[pool$pipeID %in% sub_basin] <- subset_num
    pool$source_node[pool$pipeID %in% sub_basin] <- test_data[test_data$pipeID == start_pipe[1],"downID"]
    subset_num <- subset_num + 1
    
    start_pipe <- start_pipe[-1]
    start_pipe <- c(start_pipe, end_pipes)
  }
  
  pool$new_sub_basin <- factor(pool$source_node, labels = seq_along(unique(pool$source_node)))
  
  return(pool)
}

###### Main ##########

buffer <-  c(1100,1200,1300,1400,1600,1700,1800,1900)

for(var in buffer){
  
  # Initialize an empty dataframe
  sub_basin_result <- data.frame(
    pipeID = character(0),
    basin_name = numeric(0),
    sub_basin_name = character(0),
    source_node = character(0),
    new_sub_basin = character(0),
    distance_from_start = numeric(0),
    stringsAsFactors = FALSE
  )
  
  # Execute processing for each basin
  for (i in 1:length(upstream_edges_result)) {
    cat(sprintf("Processing sub_id: %d\n", i))
    
    # Retrieve sub-basin data
    result <- set_sub_basin(i, test_data, upstream_edges_result, start_nodes, distance_mat, max_length = var)
    
    # Merge data frames (add rows)
    sub_basin_result <- rbind(sub_basin_result, result)
  }
  
  sub_basin_result$sub_basin_id <- paste(sub_basin_result$basin_name, sub_basin_result$new_sub_basin, sep = "_")
  write.csv(sub_basin_result,paste0("rawcsv/sub_basin_result_with_distance",var,".csv"))
}
