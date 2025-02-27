library(arcgisbinding)
library(sf)
library(reticulate)
library(ggplot2)
library(tmaptools)

# ArcGIS ProのPython環境を指定
arc.check_product()
use_python("C:/Program Files/ArcGIS/Pro/bin/Python/envs/arcgispro-py3/python.exe", required = TRUE)
py_config()

# ArcPyのインポート
arcpy <- import("arcpy")
arcpy$ga <- import("arcpy.ga")

# 出力データの上書きを許可
arcpy$env$overwriteOutput <- TRUE


gdb_path <- "D:/watanabe/累積人口/0809_buffer_meshmake/R/project/NewMeshSizing/NewMeshSizing.gdb"




max_lengths <- c(1100,1200,1300,1400,1600,1700,1800,1900)  # 必要に応じてこのリストを拡張
rawdata <- "D:/watanabe/累積人口/task1202/combined_result_numeric2.csv"
expnames <- c("slope","cumulative_area")


rawdata_check <- read.csv(rawdata)
str(rawdata_check)

# テーブル結合
joined <- arcpy$management$AddJoin(
  in_layer_or_view = "D:/watanabe/累積人口/1113_slopereset/project/NewMeshSizing/NewMeshSizing.gdb/管きょ_ExportFeatures_Basin_v2_ExportFeatures",
  in_field = "設備番号",
  join_table = rawdata,
  join_field = "pipeID",
  join_type = "KEEP_ALL",
  index_join_fields = "NO_INDEX_JOIN_FIELDS",
  rebuild_index = "NO_REBUILD_INDEX"
)


##ここまでは手作業のほうがよいかもしれない###########

##TIF出力ループ##
for (val in max_lengths) {
  for (expname in expnames) 
    {
    field <- paste0(expname, "_", val)
    out_raster <- paste0("D:/watanabe/累積人口/1113_slopereset/project/NewMeshSizing/", expname, "_", val, ".tif")
    
    
    
    
    tryCatch({
      # スナップラスターの設定
      arcpy$EnvManager(snapRaster = "D:/watanabe/累積人口/0809_buffer_meshmake/R/project/Buffer_Mesh/area.tif")
      
      # フィーチャーからラスターへの変換
      arcpy$conversion$FeatureToRaster(
        in_features = "D:/watanabe/累積人口/1113_slopereset/project/NewMeshSizing/NewMeshSizing.gdb/RasterT_test1_ExportFeatures",
        field = field,
        out_raster = out_raster,
        cell_size = "D:/watanabe/累積人口/0809_buffer_meshmake/R/project/Buffer_Mesh/area.tif"
      )
      
      cat(sprintf("%d %s finished\n", val, expname))
    }, error = function(e) {
      cat(sprintf("Error processing %d %s: %s\n", val, expname, e$message))
    })
  }
}


with arcpy.EnvManager(snapRaster="area.tif"):
  arcpy.conversion.FeatureToRaster(
    in_features="管きょ_ExportFeatures_Subbasin",
    field="設備番号",
    out_raster=r"D:\watanabe\累積人口\1113_slopereset\project\NewMeshSizing\test.tif",
    cell_size=r"D:\watanabe\累積人口\0809_buffer_meshmake\R\project\Buffer_Mesh\area.tif"
  )


