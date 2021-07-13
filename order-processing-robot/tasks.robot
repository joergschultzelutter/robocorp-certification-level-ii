*** Settings ***
Documentation      Orders robots from RobotSpareBin Industries Inc.
...                Saves the order HTML receipt as a PDF file.
...                Saves the screenshot of the ordered robot.
...                Embeds the screenshot of the robot to the PDF receipt.
...                Creates ZIP archive of the receipts and the images.

Library           RPA.Browser.Selenium
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF


Suite Setup       Open the robot order website
Suite Teardown    Log Out And Close The Browser

*** Test Cases ***
Order robots from RobotSpareBin Industries Inc
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form           ${row}
        Wait Until Keyword Succeeds     10x     5s    Preview the robot
        Wait Until Keyword Succeeds     10x     5s      Submit The Order
        ${orderid}=    Take a screenshot of the robot
    #     ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
    #     Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}

        Log To Console      Order Another Robot
         Go to order another robot
    END
    Create a ZIP file of the receipts

*** Keywords ***
Open the robot order website
    Open Available Browser     https://robotsparebinindustries.com/#/robot-order

Get orders
#    Download    https://robotsparebinindustries.com/orders.csv      overwrite=True
    ${table}=   Read table from CSV    orders.csv
    [Return]    ${table}

Close the annoying modal
    # Define local variables for the UI elements
    Set Local Variable              ${btn_yep}        //*[@id="root"]/div/div[2]/div/div/div/div/div/button[2]
    Wait And Click Button           ${btn_yep}

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
    # It is however assumed that all of the input elements are visible
    # when the first element has been rendered visible.
    # An even more careful approach would result in checking if e.g.
    # the given group is actually a radio button, dropdown list etc.
    # However, this was deemed out of scope for this exercise
    Wait Until Element Is Visible   ${input_head}
    Wait Until Element Is Enabled   ${input_head}
    Select From List By Value       ${input_head}           ${head}

    Wait Until Element Is Enabled   ${input_body}
    Select Radio Button             ${input_body}           ${body}

    Wait Until Element Is Enabled   ${input_legs}
    Input Text                      ${input_legs}           ${legs}
    Wait Until Element Is Enabled   ${input_address}
    Input Text                      ${input_address}        ${address}

Preview the robot
    # Define local variables for the UI elements
    Set Local Variable              ${btn_preview}      //*[@id="preview"]
    Click Button                    ${btn_preview}

Submit the order
    # Define local variables for the UI elements
    Set Local Variable              ${btn_order}        //*[@id="order"]
    Set Local Variable              ${lbl_receipt}      //*[@id="receipt"]

    Click button                    ${btn_order}
    Page Should Contain Element     ${lbl_receipt}

Take a screenshot of the robot
    # Define local variables for the UI elements
    Set Local Variable      ${lbl_orderid}      xpath://html/body/div/div/div[1]/div/div[1]/div/div/p[1]
    Set Local Variable      ${img_robot}        //*[@id="robot-preview-image"]

    # Set output dir
    Set Local Variable      ${image_folder}     bilder

    #Get the order ID
    ${orderid}=             Get Text            //*[@id="receipt"]/p[1]

    #Create the screenshot
    Capture Element Screenshot      ${img_robot}    ${image_folder}${/}${orderid}.png
    
    [Return]    ${orderid}

Go to order another robot
    # Define local variables for the UI elements
    Set Local Variable      ${btn_order_another_robot}      //*[@id="order-another"]
    Click Button            ${btn_order_another_robot}

Log Out And Close The Browser
    Close Browser

Create a Zip File of the Receipts
    Log To Console    Test