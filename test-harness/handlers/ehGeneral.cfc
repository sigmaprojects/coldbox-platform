﻿<!-----------------------------------------------------------------------
    <cffunction name="dummy" output="false" access="public" returntype="any" transactional>
    	
    </cffunction>
	<cffunction name="externalView" access="public" returntype="void" output="false" hint="">
		<cfargument name="Event"  required="yes">
	    
	    <cfset event.setView('externalview')>	     
	</cffunction>
    <cffunction name="viewCaching" output="false" access="public" returntype="any" hint="">
    	<cfargument name="Event" type="any" required="yes">
    </cffunction>

		<cfreturn instance.myMailSettings/>
	</cffunction>	
	<cffunction name="setmyMailSettings" access="public" output="false" returntype="void" hint="Set myMailSettings">
		<cfargument name="myMailSettings" type="any" required="true"/>
		<cfset instance.myMailSettings = arguments.myMailSettings/>
	</cffunction>