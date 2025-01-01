# RBC Counting and Abnormality Detection from Smartphone Images

This repository contains a MATLAB implementation for automated Red Blood Cell (RBC) counting and abnormality detection from images captured using a smartphone camera attached to a medical lab microscope. This project, originally developed offline, is now being shared publicly.

<img src="https://github.com/h4ppy0wl/myMaterials/blob/main/H1_project_icon.png">

## Overview

This project aims to provide a cost-effective and accessible solution for RBC analysis, leveraging the ubiquity of smartphones. The project is divided into two main parts, each implemented as a separate MATLAB application built with MATLAB App Designer:

1.  **H1 (Expert Knowledge Collector):** A GUI application designed for individual image processing, focusing on White Blood Cell (WBC) removal, RBC extraction and feature calculation, and expert annotation.
2.  **RBC ANFIS:** An ANFIS (Adaptive Neuro-Fuzzy Inference System) based solution for automated abnormality detection, utilizing the data collected and annotated by experts using H1.

## H1 (Expert Knowledge Collector)

<img src="https://github.com/h4ppy0wl/myMaterials/blob/main/H1_app_operator_inital_analysis.png">
This application serves as a crucial bridge between raw microscope images and the automated classification system. It provides a user-friendly interface for processing individual images and collecting expert knowledge. The workflow includes the following key steps:

*   **Image Preprocessing and WBC Removal:** The application first preprocesses the input image. A key step is the removal of WBCs, which can interfere with RBC analysis. This is achieved by creating a mask based on color channel information. The application offers several binarization methods for creating this mask, providing flexibility for different image qualities and conditions:
   *   **Adaptive Binarization (adaptthresh):** This technique dynamically determines a threshold for image segmentation based on local image characteristics. Unlike global thresholding methods that use a single threshold for the entire image, adaptive thresholding calculates a different threshold for each pixel based on the intensity values in its surrounding neighborhood. This makes it much more robust to variations in lighting, background illumination, and image contrast across the image.
   
   *   **Otsu's Method (otsuthresh):** otsuthresh(counts) computes a global threshold T from histogram counts, counts, using Otsu's method. Otsu's method chooses a threshold that minimizes the intraclass variance of the thresholded black and white pixels. The global threshold T can be used with imbinarize to convert a grayscale image to a binary image.
   *   **Gray threshold Method (graythresh):** graythresh(I) computes a global threshold T from grayscale image I, using Otsu's method.
   *   **Custom Algorithm:** A custom-developed algorithm using image processing concepts such as binarization, morphological operations (erosion, dilation, opening, closing), area opening, and hole filling. This provides fine-grained control over the WBC masking process.
    Morphological operations (opening and closing) are used to refine the mask, removing noise and small artifacts, regardless of the binarization method used. The application provides flexibility by allowing users to select different color spaces and adjust parameters for the binarization and morphological operations.
*   **RBC Extraction:** After WBC removal, the application focuses on isolating individual RBCs. Techniques like the Hough transform and Watershed segmentation are employed to identify and separate RBCs, even in cases where cells overlap or clump together. This ensures accurate counting and feature extraction for each individual cell.
*   **Feature Extraction:** For each extracted RBC, a set of texture features is calculated using the Gray-Level Co-occurrence Matrix (GLCM). These features, including Homogeneity, Correlation, Energy, and Contrast, capture important textural characteristics of the cells, which can be indicative of various abnormalities.
*   **Expert Annotation:** A dedicated GUI within H1 allows medical experts to visually inspect each extracted RBC and classify it based on established medical criteria. The expert can categorize cells as Normal, or identify specific abnormalities such as Target cells, Spherocytes, Hyperchromic cells, or Hypochromic cells. An "Unknown" category is also available for ambiguous cases. This expert annotation provides the ground truth data for training the RBC ANFIS model. The application also records cell counts within each processed image.
*   **Data Management:** All processing settings, extracted features, expert annotations, and cell counts are stored in a structured `.mat` file format. This allows for easy storage, retrieval, and transfer of data between H1 and the RBC ANFIS application. The application allows saving and loading of analysis progress.
<img src="https://github.com/h4ppy0wl/myMaterials/blob/main/H1_Operator_app_options.png">

## RBC ANFIS

<img src="https://github.com/h4ppy0wl/myMaterials/blob/main/RBC_ANFIS_app_ss.png">
The RBC ANFIS application leverages the expert-annotated data collected by H1 to train an Adaptive Neuro-Fuzzy Inference System (ANFIS) for automated RBC abnormality detection. This system aims to mimic the human-in-the-loop approach used in commercial hematology analyzers, where human experts validate and refine the system's performance.

*   **ANFIS Training and Evaluation:** The application takes the `.mat` files generated by H1 as input. The data is divided into training and testing sets. The ANFIS model is then trained on the training data, learning the relationships between the extracted GLCM features and the expert-provided classifications. The trained model's performance is then evaluated on the testing data.
*   **Reporting and Parameter Tuning:** The application generates comprehensive reports summarizing the training and testing results. These reports provide key metrics and visualizations that help system engineers understand the model's performance and identify areas for improvement. This information guides the adjustment of ANFIS parameters, allowing for iterative refinement of the automated classification system.

## Features

*   Automated RBC counting and abnormality detection.
*   User-friendly GUI applications for data collection (H1) and automated classification (RBC ANFIS), built with MATLAB App Designer.
*   Robust WBC removal and RBC extraction methods.
*   Intuitive expert annotation interface.
*   ANFIS-based automated classification of RBC abnormalities.
*   Comprehensive reporting for ANFIS model tuning and performance evaluation.
*   Flexible parameter settings for image processing and analysis.

## Disclaimer

**This project is provided as-is, for educational and research purposes only. It is not a complete or clinically validated solution and should not be used for diagnostic purposes. The authors do not assume any responsibility or liability for any consequences arising from the use of this software.**

This project was developed as part of [mention the context, e.g., a university project, personal exploration, etc.] and is being shared in its current state. While efforts have been made to ensure the functionality of the code, it may contain errors or limitations. Users are advised to use this software at their own discretion and understand its experimental nature.


## Getting Started

### Prerequisites

*   MATLAB 2018b (This project was developed and tested using MATLAB 2018b. Compatibility with other versions is not guaranteed. Although I successfully did a limited test of MATLAB 2023a)
*   Image Processing Toolbox
*   Fuzzy Logic Toolbox
*   MATLAB App Designer (Used for GUI development)

### Usage

1.  Clone the repository: `git clone https://github.com/[YourUsername]/[YourRepository].git`
2.  Open MATLAB 2018b and navigate to the project directory.
3.  Run H1 and RBC ANFIS.

## Theories Used

*   **Adaptive Binarization:** A dynamic thresholding technique that adapts to local image characteristics for more accurate segmentation.
*   **Hough Transform:** A feature extraction technique used for detecting shapes, particularly circles (relevant for RBC detection).
*   **Watershed Segmentation:** A powerful image segmentation method used to separate touching objects.
*   **Gray-Level Co-occurrence Matrix (GLCM):** A statistical method for analyzing texture by examining the spatial relationships between pixel gray levels.
*   **Adaptive Neuro-Fuzzy Inference System (ANFIS):** A hybrid intelligent system that combines neural networks and fuzzy logic for learning and reasoning.

## License

GPL-3.0 license

## Acknowledgements

I want to thank you Gevik Karpians for his invaluable help in collecting blood smear images and analyzing a set of images as the subject matter expert.
