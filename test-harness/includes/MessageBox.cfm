﻿<cfsetting enablecfoutputonly=true><cfset msgClass = ""><cfif msgStruct.type eq "error">	<cfset msgClass = " alert-error"><cfelseif msgStruct.type eq "info">	<cfset msgClass = " alert-info"></cfif><cfoutput><div class="alert#msgClass#" data-type="#msgStruct.type#">#msgStruct.message#</div></cfoutput><cfsetting enablecfoutputonly="false">