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
    Preview the robot
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

    # Extract the values from the  dictionary
    Set Local Variable    ${order_no}   ${myrow}[Order number]
    Set Local Variable    ${head}       ${myrow}[Head]
    Set Local Variable    ${body}       ${myrow}[Body]
    Set Local Variable    ${legs}       ${myrow}[Legs]
    Set Local Variable    ${address}    ${myrow}[Address]

    # Define local variables for the UI elements
    # "legs" UID changes all the time so this one uses an
    # absolute xpath. I prefer local variables over 
    # "Assign ID To Element" as the latter does not seem
    # to be able to use a full XPath reference
    Set Local Variable      ${input_head}       //*[@id="head"]
    Set Local Variable      ${input_body}       body
    Set Local Variable      ${input_legs}       xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input
    Set Local Variable      ${input_address}    //*[@id="address"]
    Set Local Variable      ${btn_preview}      //*[@id="preview"]
    Set Local Variable      ${btn_order}        //*[@id="order"]
    Set Local Variable      ${img_preview}      //*[@id="robot-preview-image"]

    # Input the data. I use a "cautious" approach and assume
    # that there are situations when a field is not yet visible
    # An even more careful approach would result in checking if e.g.
    # the given group is actually a radio button, dropdown list etc.
    # However, this was deemed out of scope for this exercise
    Wait Until Element Is Visible   ${input_head}
    Select From List By Value       ${input_head}           ${head}

    Wait Until Element Is Visible   ${input_body}
    Select Radio Button             ${input_body}           ${body}

    Wait Until Element Is Visible   ${input_legs}
    Input Text                      ${input_legs}           ${legs}
    Wait Until Element Is Visible   ${input_address}
    Input Text                      ${input_address}        ${address}

Preview the robot
    # Define local variables for the UI elements
    Set Local Variable              ${btn_preview}      //*[@id="preview"]
    Click Button                    ${btn_preview}

Submit the order
    # Define local variables for the UI elements
    # "legs" UID changes all the time so this one uses an
    # absolute xpath. I prefer local variables over 
    # "Assign ID To Element" as the latter does not seem
    # to be able to use a full XPath reference
    Set Local Variable      ${btn_order}        //*[@id="order"]
    Set Local Variable      ${img_preview}      //*[@id="robot-preview-image"]



Log Out And Close The Browser
#    Click Button    Log out
    Close Browser