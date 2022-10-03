*** Settings ***
Documentation       Inhuman Insurance, Inc. Artifucual Intelligence System robot

Library             RPA.HTTP
Library             RPA.JSON
Library             RPA.Tables


*** Variables ***
### VARIBLES ###
${JSONFILEURL}      https://github.com/robocorp/inhuman-insurance-inc/raw/main/RS_198.json
${JSONFILEPATH}     ${OUTPUT_DIR}${/}traffic.json


*** Tasks ***
Produce traffic data work items
    Download traffic data
    ${traffic_data}=    Load traffic data as tables
    ${filtered_data}=    Filter and sort traffic data    ${traffic_data}


*** Keywords ***
Download traffic data
    Download
    ...    ${JSONFILEURL}
    ...    ${JSONFILEPATH}
    ...    overwrite=True

Load traffic data as tables
    ${json}=    Load JSON from file    ${JSONFILEPATH}
    ${table}=    Create Table    ${json}[value]
    RETURN    ${table}

Filter and sort traffic data
    [Arguments]    ${table}
    ${max_rate}=    Set Variable    ${5.0}
    ${rate_key}=    Set Variable    NumericValue
    ${gender_key}=    Set Variable    Dim1
    ${both_genders}=    Set Variable    BTSX
    ${year_key}=    Set Variable    TimeDim
    Filter Table By Column    ${table}    ${rate_key}    <    ${max_rate}
    Filter Table By Column    ${table}    ${gender_key}    ==    ${both_genders}
    Sort Table By Column    ${table}    ${year_key}    false
    RETURN    ${table}
