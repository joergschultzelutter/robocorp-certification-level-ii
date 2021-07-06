*** Settings ***
Documentation      Orders robots from RobotSpareBin Industries Inc.
...                Saves the order HTML receipt as a PDF file.
...                Saves the screenshot of the ordered robot.
...                Embeds the screenshot of the robot to the PDF receipt.
...                Creates ZIP archive of the receipts and the images.

Library           RPA.Browser.Selenium
Library           RPA.HTTP
Library           RPA.Tables

Suite Setup       Open the robot order website
Suite Teardown    Log Out And Close The Browser

*** Test Cases ***
Order robots from RobotSpareBin Industries Inc
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}

    #     Close the annoying modal
    Fill the form           ${row}
    #     Preview the robot
    #     Submit the order
    #     ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
    #     ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
    #     Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
    #     Go to order another robot
    END
    # Create a ZIP file of the receipts

*** Keywords ***
Open the robot order website
    Open Available Browser     https://robotsparebinindustries.com/#/robot-order
    Click Button               Yep

Get orders
    Download    https://robotsparebinindustries.com/orders.csv      overwrite=True
    ${table}=   Read table from CSV    orders.csv
    [Return]    ${table}

Close the annoying modal
    Click Button When Visible   Yep


Fill the form
    [Arguments]     ${myrow}

    Set Local Variable    ${order_no}   ${myrow}[Order number]
    Set Local Variable    ${head}       ${myrow}[Head]
    Set Local Variable    ${body}       ${myrow}[Body]
    Set Local Variable    ${legs}       ${myrow}[Legs]
    Set Local Variable    ${address}    ${myrow}[Address]


    Input Text When Element Is Visible           xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input      ${legs}
    Input Text When Element Is Visible           address            ${address}


Log Out And Close The Browser
#    Click Button    Log out
    Close Browser