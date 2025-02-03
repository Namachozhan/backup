terraform {
  backend "azurerm" {
    storage_account_name = "eaifdevopsstorage"
    container_name       = "eaifdevopsterraform"
    key                  = "terraform.tfstate"
    sas_token            = "sv=2022-11-02&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2025-01-30T20:26:26Z&st=2025-01-17T12:26:26Z&spr=https,http&sig=JtXbx3q2fl989U2CcuMYT7OEa7anBWC%2Fsa19VG2PmxQ%3D"
  }
}