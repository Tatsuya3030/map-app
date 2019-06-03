library(rgdal)
library(dplyr)
library(maptools)
library(rmapshaper)

#シェープファイル読み込み
shape <- readOGR("./shape", layer = "N03-14_140401", encoding = 'shift-JIS',
               stringsAsFactors = FALSE)

#データフレーム作成（都道府県名とidの列だけ）
shape_df <- as(shape, "data.frame")
shape_df_pref <- shape_df %>%
  group_by(N03_001) %>%
  summerise()
shape_df_pref$pref_id <- row.names(shape_df_pref)

# polygonの結合
shhape_merged <- merge(shape, shape_df_pref)
shape_union <- unionSpatialPolygons(shape_merged, shape_merged@data$pref_id)

# spatialdataframeに直す
regions_unions <- sp::SpatialPolygonsDataFrame(shape_union, shape_df_pref)

# 簡素化
regions <- ms_simplify(regions_unions)
regions@data <- subset(regions@data, select = -c(pref_id))

# シェープファイルとして保存
writeOGR(regions, "./shape", "sample", layer_options = "ENCODING=UTF-8",
         driver = "ESRI Shapefile")