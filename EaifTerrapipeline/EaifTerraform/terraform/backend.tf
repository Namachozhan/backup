terraform {
  backend "azurerm" {
    storage_account_name = "eaifdevopspython"
    container_name       = "winrmtest"
    key                  = "terraform.tfstate"
    sas_token            = "sv=2022-11-02&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2025-12-20T16:19:13Z&st=2025-02-20T08:19:13Z&spr=https,http&sig=bblOW1YzUdxMfxnd1fFdCasyUeus4GFPzNsLNi%2Bz8iE%3D"
  }
}
