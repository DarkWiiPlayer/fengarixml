package = "fengarixml"
version = "dev-1"
source = {
   url = "git://github.com/DarkWiiPlayer/fengarixml.git";
}
description = {
   homepage = "https://github.com/DarkWiiPlayer/fengarixml";
   license = "Unlicense";
}
dependencies = {
  "lua >= 5.1";
}
build = {
   type = "builtin",
   modules = {
     moonxml = 'xml.lua'
   }
}
