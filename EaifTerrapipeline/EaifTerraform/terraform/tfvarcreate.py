import json, hcl2
from random import randint
 
APIVMDetailFile = "input.json"
existingVMDetailFile = "value.tfvars"
outputVMDetailFile = "tfVMDetailsOut.tfvars"
 
def append_tf_variables():
 
    #Read the API Output json file
    with open(APIVMDetailFile, 'r') as file:
        inputJson = json.load(file)    
 
    #Read the existing terraform vm details file
    with open(existingVMDetailFile, "r") as file_in:
        current_tfvars_content = hcl2.load(file_in)    
 
    #Write all the existing terraform variables
    finalText = "vm_map = {\n" 
    for key, value in current_tfvars_content['vm_map'].items():
        finalText = finalText + "\"" + key  + "\" = {\n"
        for key1,value1 in value.items():    
            finalText = finalText + key1 + " = \"" + value1 + "\"" + "\n"
        finalText = finalText + "}\n"
 
    #Appen the terraform variables received from API
    vmNameStr = ""
    vmNameList = []
    first = True    
    for key, value in inputJson.items():
        #Get the unique vmName
        tmpVMName = "vm" + str(randint(10, 99))
        while True:
            if tmpVMName not in vmNameList: vmNameList.append(tmpVMName) ; break
            else:  tmpVMName = "vm" + str(randint(10, 99))         
 
        #Prepare the output to contain unique VM names that is generated        
        if first: vmNameStr = vmNameStr + tmpVMName ; first = False
        else:  vmNameStr = vmNameStr + "," +  tmpVMName
 
        #Write the unique VM Name generated and its details
        finalText = finalText + "\"" + tmpVMName  + "\" = {\n"
        for key1,value1 in value.items():    
            finalText = finalText + key1 + " = \"" + value1 + "\"" + "\n"
        finalText = finalText + "}\n"
    finalText = finalText + "}"
    #Write all the VM details to file
    with (open(outputVMDetailFile, "a")) as f:
        f.write(finalText)   
    #print(vmNameStr)  # Ensure this is the last line of the script        
 
    return vmNameStr

print(append_tf_variables())