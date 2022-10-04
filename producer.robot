*** Settings ***
Documentation       Inhuman Insurance, Inc. Artifucual Intelligence System robot

Library             Collections
Library             RPA.HTTP
Library             RPA.JSON
Library             RPA.Tables
Library             RPA.JSON
Library             RPA.Robocorp.WorkItems
Resource            shared.robot


*** Variables ***
### VARIBLES ###
${JSONFILEURL}      https://github.com/robocorp/inhuman-insurance-inc/raw/main/RS_198.json
${JSONFILEPATH}     ${OUTPUT_DIR}${/}traffic.json
# JSON data keys:
${COUNTRY_KEY}=     SpatialDim
${GENDER_KEY}=      Dim1
${RATE_KEY}=        NumericValue
${YEAR_KEY}=        TimeDim


*** Tasks ***
Produce traffic data work items
    Download traffic data
    ${traffic_data}=    Load traffic data as tables
    ${filtered_data}=    Filter and sort traffic data    ${traffic_data}
    ${filtered_data}=    Get latest data by country    ${filtered_data}
    ${payloads}=    Create work items payloads    ${filtered_data}
    Save work item payload    ${payloads}


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

Get latest data by country
    [Arguments]    ${table}
    ${country_key}=    Set Variable    SpatialDim
    ${table}=    Group Table By Column    ${table}    ${country_key}
    ${latest_data_by_country}=    Create List
    FOR    ${group}    IN    @{table}
        ${first_row}=    Pop Table Row    ${group}
        Append To List    ${latest_data_by_country}    ${first_row}
    END

    RETURN    ${latest_data_by_country}

Create work items payloads
    [Arguments]    ${traffic_data}
    ${payloads}=    Create List
    FOR    ${row}    IN    @{traffic_data}
        ${payload}=
        ...    Create Dictionary
        ...    country=${row}[${COUNTRY_KEY}]
        ...    year=${row}[${YEAR_KEY}]
        ...    rate=${row}[${RATE_KEY}]
        Append To List    ${payloads}    ${payload}
    END
    RETURN    ${payloads}

Save work item payload
    [Arguments]    ${payload}
    ${variables}=    Create Dictionary    ${WORK_ITEM_NAME}=${payload}
    Create Output Work Item    variables=${variables}    save=True
