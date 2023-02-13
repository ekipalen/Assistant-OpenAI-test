*** Settings ***
Documentation       Assistant bot that uses RPA.OpenAI library. 
Library             OperatingSystem
Library             RPA.Assistant
Library             RPA.OpenAI
Library             RPA.Robocorp.Vault
Library             RPA.Desktop
Library             RPA.HTTP

*** Variables ***
${counter}    1

*** Tasks ***
Main
    [Documentation]
    ...    The Main task running the Assistant
    ...    Configure your window behaviour here   
    Get Secrets and Authorize to OpenAI
    Display Main Menu
    ${result}=    RPA.Assistant.Run Dialog
    ...    title=Robocorp
    ...    on_top=True
    ...    height=540
    ...    width=600

*** Keywords ***
Get Secrets and Authorize to OpenAI
    # Get the OpenAI API key from Robocorp Vault.
    ${secrets}   Get Secret   OpenAI
    # For testing it is possible to use your API key directly here but it would be bad for security.
    Authorize To Openai   api_key=${secrets}[key]

Display Main Menu
    Clear Dialog
    Add Heading    Robocorp - OpenAI Assistant
    Add Text    Available Actions:
    Add Button    Create OpenAI text Completion    Text Completion Window
    Add Button    Create DALL-E images    Image Create Window
    Add Submit Buttons    buttons=Close    default=Close

Back To Main Menu
    [Arguments]   ${result}
    Display Main Menu
    Refresh Dialog

Text Completion Window
    Clear Dialog
    Add Heading    Create text Completion   size=Small
    Add Text Input    prompt_input    Input prompt 
    Add Next Ui Button    Create     Create a Completion   
    Add Next Ui Button    Back    Back To Main Menu
    Refresh Dialog

Image Create Window
    Clear Dialog
    Add Heading    Create images with DALL-E   size=Small
    Add Text Input    image_input    Input prompt 
    Add Drop-down
    ...    name=num
    ...    options=1,2,3
    ...    default=1
    ...    label=Number of images
    Add Drop-down
    ...    name=size
    ...    options=256x256,512x512,1024x1024
    ...    default=512x512
    ...    label=Image Size      
    Add checkbox    name=download     label=Download images    default=False
    Add Next Ui Button    Create     Create a Image   
    Add Next Ui Button    Back    Back To Main Menu
    Refresh Dialog

Create a Completion
    [Arguments]   ${form}
    ${completion_from_openai}   Completion Create    ${form}[prompt_input]
    Clear Dialog
    Add Heading    Text Completion
    Add text    ${completion_from_openai}
    Add Button    Copy to clipboard    Set clipboard value   ${completion_from_openai}
    Add Next Ui Button    Back    Back To Main Menu
    Refresh Dialog

Create a Image
    [Arguments]   ${form}
    ${image_urls}    Image Create     prompt=${form}[image_input]   size=${form}[size]   num_images=${form}[num]
    Clear Dialog
    Add Heading    DALL-E Images   size=Small
    FOR    ${url}    IN    @{image_urls}
        ${width}   Get Image Width    ${form}[size]
        Add image   ${url}   width=${width}
        Add link    ${url}   Open Image in default browser   
        ${counter}   Evaluate    ${counter}+1
        IF    '${form}[download]' == 'true'
            Download   ${url}    
        END
    END
    Add Next Ui Button    Back    Back To Main Menu
    Refresh Dialog

Get Image Width
    [Arguments]   ${size}
    IF    '${size}' == '256x256'
        ${width}   Set Variable   256
    ELSE
        ${width}   Set Variable   512
    END
    [Return]   ${width}
