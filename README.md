
# プロジェクト概要

このプロジェクトは、パイプラインネットワークのデータを処理し、サブ流域（Subbasin）を設定し、各サブ流域における傾斜（slope）と累積面積（cumulative area）の加重平均を計算し、その結果をラスター形式で出力することを目的としています。主に以下の4つのスクリプトで構成されています。

1. **SetSUBbasin.R**: パイプラインネットワークをサブ流域に分割し、各サブ流域の情報をCSVファイルに保存します。
2. **BufferChange_for_subbasin.R**: サブ流域ごとに傾斜と累積面積の逆距離加重平均を計算し、結果をCSVファイルに保存します。
3. **data_connection.R**: 異なる距離（1100, 1200, ..., 1900）ごとに計算された加重平均データを結合し、1つのCSVファイルにまとめます。
4. **Set_raster_subbasin.R**: 結合されたデータをArcGIS Proを使用してラスター形式に変換し、TIFファイルとして出力します。

## スクリプトの詳細

### 1. SetSUBbasin.R
- **目的**: パイプラインネットワークをサブ流域に分割し、各サブ流域の情報をCSVファイルに保存します。
- **入力ファイル**:
  - `test_data.csv`: パイプラインデータ（傾斜、累積面積、パイプ長など）。
  - `distance_matrics.csv`: 距離行列データ。
  - `100point_2.csv`: 開始ノードのリスト。
  - `upstream_edges_5000_Rdata.RData`: 上流エッジのデータ。
- **出力ファイル**:
  - `sub_basin_result_with_distance{距離}.csv`: サブ流域の情報（距離ごとに異なるファイル）。

### 2. BufferChange_for_subbasin.R
- **目的**: サブ流域ごとに傾斜（slope）と累積面積（cumulative area）の逆距離加重平均を計算します。
- **入力ファイル**:
  - `test_data.csv`: パイプラインデータ（傾斜、累積面積、パイプ長など）。
  - `sub_basin_result_with_distance{距離}.csv`: サブ流域の情報（距離ごとに異なるファイル）。
- **出力ファイル**:
  - `weighted_average_{距離}.csv`: 各サブ流域の加重平均を記録したCSVファイル。

### 3. data_connection.R
- **目的**: 異なる距離（1100, 1200, ..., 1900）ごとに計算された加重平均データを結合し、1つのCSVファイルにまとめます。
- **入力ファイル**:
  - `sub_basin_result_with_distance{距離}.csv`: サブ流域の情報。
  - `weighted_average_{距離}.csv`: 加重平均データ。
- **出力ファイル**:
  - `combined_result3.csv`: 結合されたデータ（NA値を含む）。
  - `combined_result_numeric3.csv`: NA値を-9999に置換したデータ。

### 4. Set_raster_subbasin.R
- **目的**: 結合されたデータをArcGIS Proを使用してラスター形式に変換し、TIFファイルとして出力します。
- **入力ファイル**:
  - `combined_result_numeric2.csv`: 結合されたデータ。
- **出力ファイル**:
  - `slope_{距離}.tif`: 傾斜のラスターデータ。
  - `cumulative_area_{距離}.tif`: 累積面積のラスターデータ。
 - **注意**:
   - **Rのバージョンは4.1.2**で実行してください。　　　 

## 使用ツールとライブラリ
- **R**: データ処理と計算に使用。
- **ArcGIS Pro**: ラスターデータの生成に使用。
- **Rライブラリ**:
  - `dplyr`: データ操作。
  - `readr`: CSVファイルの読み込み。
  - `arcgisbinding`: ArcGIS Proとの連携。
  - `sf`, `reticulate`, `ggplot2`, `tmaptools`: その他の補助ライブラリ。

## プロジェクトの流れ
以下に、各スクリプトの出力が次のスクリプトの入力になる関係を整理し、確認します。

### 1. **SetSUBbasin.R**
- **目的**: パイプラインネットワークをサブ流域に分割し、各サブ流域の情報をCSVファイルに保存します。
- **入力ファイル**:
  - `test_data.csv`: パイプラインデータ（傾斜、累積面積、パイプ長など）。
  - `distance_matrics.csv`: 距離行列データ。
  - `100point_2.csv`: 開始ノードのリスト。
  - `upstream_edges_5000_Rdata.RData`: 上流エッジのデータ。
- **出力ファイル**:
  - `sub_basin_result_with_distance{距離}.csv`: サブ流域の情報（距離ごとに異なるファイル）。

**次のスクリプトへの入力**:  
`sub_basin_result_with_distance{距離}.csv` は **BufferChange_for_subbasin.R** の入力として使用されます。

---

### 2. **BufferChange_for_subbasin.R**
- **目的**: サブ流域ごとに傾斜（slope）と累積面積（cumulative area）の逆距離加重平均を計算します。
- **入力ファイル**:
  - `test_data.csv`: パイプラインデータ（傾斜、累積面積、パイプ長など）。
  - `sub_basin_result_with_distance{距離}.csv`: サブ流域の情報（距離ごとに異なるファイル）。
- **出力ファイル**:
  - `weighted_average_{距離}.csv`: 各サブ流域の加重平均を記録したCSVファイル。

**次のスクリプトへの入力**:  
`weighted_average_{距離}.csv` は **data_connection.R** の入力として使用されます。

---

### 3. **data_connection.R**
- **目的**: 異なる距離（1100, 1200, ..., 1900）ごとに計算された加重平均データを結合し、1つのCSVファイルにまとめます。
- **入力ファイル**:
  - `sub_basin_result_with_distance{距離}.csv`: サブ流域の情報。
  - `weighted_average_{距離}.csv`: 加重平均データ。
- **出力ファイル**:
  - `combined_result3.csv`: 結合されたデータ（NA値を含む）。
  - `combined_result_numeric3.csv`: NA値を-9999に置換したデータ。

**次のスクリプトへの入力**:  
`combined_result_numeric3.csv` は **Set_raster_subbasin.R** の入力として使用されます。

---

### 4. **Set_raster_subbasin.R**
- **目的**: 結合されたデータをArcGIS Proを使用してラスター形式に変換し、TIFファイルとして出力します。
- **入力ファイル**:
  - `combined_result_numeric2.csv`: 結合されたデータ。
- **出力ファイル**:
  - `slope_{距離}.tif`: 傾斜のラスターデータ。
  - `cumulative_area_{距離}.tif`: 累積面積のラスターデータ。
- **注意点**
  - Rのバージョンは4.1.2で実行してください。

---

### 全体の流れ
1. **SetSUBbasin.R** がサブ流域を分割し、`sub_basin_result_with_distance{距離}.csv` を生成。
2. **BufferChange_for_subbasin.R** が `sub_basin_result_with_distance{距離}.csv` を入力として受け取り、加重平均を計算し、`weighted_average_{距離}.csv` を生成。
3. **data_connection.R** が `sub_basin_result_with_distance{距離}.csv` と `weighted_average_{距離}.csv` を入力として受け取り、データを結合し、`combined_result3.csv` と `combined_result_numeric3.csv` を生成。
4. **Set_raster_subbasin.R** が `combined_result_numeric3.csv` を入力として受け取り、ラスターデータ（TIFファイル）を生成。

---

### 入出力関係の図解
```plaintext
SetSUBbasin.R
  ↓ (出力: sub_basin_result_with_distance{距離}.csv)
BufferChange_for_subbasin.R
  ↓ (出力: weighted_average_{距離}.csv)
data_connection.R
  ↓ (出力: combined_result3.csv, combined_result_numeric3.csv)
Set_raster_subbasin.R
  ↓ (出力: slope_{距離}.tif, cumulative_area_{距離}.tif)
```


### 確認ポイント
- **SetSUBbasin.R** の出力ファイル `sub_basin_result_with_distance{距離}.csv` は、**BufferChange_for_subbasin.R** の入力として使用されます。
- **BufferChange_for_subbasin.R** の出力ファイル `weighted_average_{距離}.csv` は、**data_connection.R** の入力として使用されます。
- **data_connection.R** の出力ファイル `combined_result_numeric3.csv` は、**Set_raster_subbasin.R** の入力として使用されます。


## 注意点
- ArcGIS Proの環境設定が必要です。特にPython環境の指定に注意してください。
- 各スクリプトは順番に実行する必要があります。特に、`SetSUBbasin.R` → `BufferChange_for_subbasin.R` → `data_connection.R` → `Set_raster_subbasin.R` の順で実行してください。

## 作者
- kanki-watanabe (kanki.watanabe.s2@dc.tohoku.ac.jp)


