if(fs.exists("ChibbiScripts/")) then
    fs.delete("ChibbiScripts/")
end
fs.makeDir("ChibbiScripts/")


http.request("ChibbiScripts/scriptList.txt")


local requesting = true

while requesting do
  local event, url, sourceText = os.pullEvent()
  
  if event == "http_success" then
    local respondedText = sourceText.readAll()
    
    sourceText.close()
    print(respondedText)
    
    requesting = false
  elseif event == "http_failure" then
    print("Server didn't respond.")
    
    requesting = false
  end
end