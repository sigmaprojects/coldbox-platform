<!-----------------------------------------------------------------------
Template : baseTest.cfc
Author 	  : Luis Majano
Date        : 5/25/2007
Description :
	Base Unit Test Component based on MXUnit.
	{ADD MORE DESCRIPTION HERE}
	
	This is a base test component for testing coldbox handlers. All you need
	to do is add the extends portions of your test cases to this base test
	and you will have a coldbox handler test.  The setup method will need
	to be changed in order to match your application path.

	MODIFY:
	1) instance.AppMapping : To point to your application relative from the root
	                         or via CF Mappings.
	2) instance.ConfigMapping : The expanded path location of your coldbox configuration file.

	OPTIONAL:
	3) Execute the on App start handler. You will need to fill out the name
	   of the Application Start Handler to be executed.

---------------------------------------------------------------------->
<cfcomponent name="BaseTestCase" 
			 extends="mxunit.framework.TestCase" 
			 output="false" 
			 hint="A base unit test case for MXUnit">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		variables.instance = structnew();
		instance.AppMapping = "";
		instance.ConfigMapping = "";
		instance.controller = "";
		/* Public Persistence Properties */
		this.PERSIST_FRAMEWORK = true;
	</cfscript>

	<cffunction name="setup" returntype="void" access="public">
		<cfscript>
		/* Check on Scope Firsty */
		if( structKeyExists(application,"cbController") ){
			instance.controller = application.cbController;
		}
		else{
			//Initialize ColdBox
			instance.controller = CreateObject("component", "coldbox.system.testing.TestController").init( expandPath(instance.AppMapping) );
			/* Verify Persistence */
			if( this.PERSIST_FRAMEWORK ){
				application.cbController = instance.controller;
			}
			/* Setup */
			instance.controller.getLoaderService().configLoader(instance.ConfigMapping,instance.AppMapping);
		}
		
		//Create Initial Event Context
		setupRequest();
		
		//Clean up Initial Event Context
		getRequestContext().clearCollection();
		</cfscript>
	</cffunction>
	
	<cffunction name="tearDown" access="public" returntype="void" hint="The teardown" output="false" >
		<cfscript>
			
		</cfscript>
	</cffunction>

<!------------------------------------------- HELPERS ------------------------------------------->

	<!--- Reset the persistence --->
	<cffunction name="reset" access="private" returntype="void" hint="Reset the persistence of the unit test coldbox app" output="false" >
		<cfset structDelete(application,"cbController")>
	</cffunction>

	<!--- getter for AppMapping --->
	<cffunction name="getAppMapping" access="private" returntype="string" output="false" hint="Get the AppMapping">
		<cfreturn instance.AppMapping>
	</cffunction>
	
	<!--- setter for AppMapping --->
	<cffunction name="setAppMapping" access="private" output="false" returntype="void" hint="Set the AppMapping">
		<cfargument name="AppMapping" type="string" required="true"/>
		<cfset instance.AppMapping = arguments.AppMapping/>
	</cffunction>

	<!--- getter for ConfigMapping --->
	<cffunction name="getConfigMapping" access="private" returntype="string" output="false" hint="Get the ConfigMapping">
		<cfreturn instance.ConfigMapping>
	</cffunction>
	
	<!--- setter for ConfigMapping --->
	<cffunction name="setConfigMapping" access="private" output="false" returntype="void" hint="Set the ConfigMapping">
		<cfargument name="ConfigMapping" type="string" required="true"/>
		<cfset instance.ConfigMapping = arguments.ConfigMapping/>
	</cffunction>

	<!--- getter for controller --->
	<cffunction name="getcontroller" access="private" returntype="any" output="false" hint="Get a reference to the ColdBox controller">
		<cfif this.PERSIST_FRAMEWORK>
			<cfset instance.controller = application.cbController>
		</cfif>
		<cfreturn instance.controller>
	</cffunction>

	<!--- Get current request context --->
	<cffunction name="getRequestContext" access="private" output="false" returntype="any" hint="Get the event object">
		<cfreturn getController().getRequestService().getContext() >
	</cffunction>

	<!--- Setup a request context --->
	<cffunction name="setupRequest" access="private" output="false" returntype="void" hint="Setup a request with FORM/URL data">
		<cfset getController().getRequestService().requestCapture() >
	</cffunction>

	<!--- prepare request, execute request and retrieve request --->
	<cffunction name="execute" access="private" output="false" returntype="any" hint="Executes a framework lifecycle">
		<cfargument name="eventhandler" required="true" type="string" hint="The event to execute">
		<cfargument name="private" required="false" type="boolean" default="false" hint="Call a private event or not">
		<cfscript>
			var handlerResults = "";
			var requestContext = "";
			
			//Setup the request Context with setup FORM/URL variables set in the unit test.
			setupRequest();
			
			//TEST EVENT EXECUTION
			handlerResults = getController().runEvent(event=eventhandler,private=arguments.private);
			
			//Return the correct event context.
			requestContext = getRequestContext();
			
			//If we have results save
			if ( isDefined("handlerResults") ){
				requestContext.setValue("cbox_handler_results", handlerResults);
			}
			
			return requestContext;
		</cfscript>
	</cffunction>
	
	<!--- Announce Interception --->
	<cffunction name="announceInterception" access="private" returntype="void" hint="Announce an interception to the system." output="false" >
		<cfargument name="state" 			required="true"  type="string" hint="The interception state to execute">
		<cfargument name="interceptData" 	required="false" type="struct" default="#structNew()#" hint="A data structure used to pass intercepted information.">
		<cfset getController().getInterceptorService().processState(argumentCollection=arguments)>
	</cffunction>

	<!--- Interceptor Facade --->
	<cffunction name="getInterceptor" access="private" output="false" returntype="any" hint="Get an interceptor">
		<!--- ************************************************************* --->
		<cfargument name="interceptorClass" required="true" type="string" hint="The qualified class of the itnerceptor to retrieve">
		<!--- ************************************************************* --->
		<cfscript>
			return getController().getInterceptorService().getInterceptor(arguments.interceptorClass);
		</cfscript>
	</cffunction>
	
	<!--- Get Model --->
	<cffunction name="getModel" access="private" returntype="any" hint="Create or retrieve model objects by convention" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 				required="true"  type="string" hint="The name of the model to retrieve">
		<cfargument name="useSetterInjection" 	required="false" type="boolean" default="false"	hint="Whether to use setter injection alongside the annotations property injection. cfproperty injection takes precedence.">
		<cfargument name="onDICompleteUDF" 		required="false" type="string"	default="onDIComplete" hint="After Dependencies are injected, this method will look for this UDF and call it if it exists. The default value is onDIComplete">
		<cfargument name="debugMode" 			required="false" type="boolean" default="false" hint="Debugging Mode or not">
		<!--- ************************************************************* --->
		<cfreturn getController().getPlugin("BeanFactory").getModel(argumentCollection=arguments)>
	</cffunction>

	<!--- Dump facade --->
	<cffunction name="dumpit" access="private" hint="Facade for cfmx dump" returntype="void">
		<cfargument name="var" required="yes" type="any">
		<cfargument name="isAbort" type="boolean" default="false" required="false" hint="Abort also"/>
		<cfdump var="#var#">
		<cfif arguments.isAbort><cfabort></cfif>
	</cffunction>
	<!--- Rethrow Facade --->
	<cffunction name="rethrowit" access="private" returntype="void" hint="Rethrow facade" output="false" >
		<cfargument name="throwObject" required="true" type="any" hint="The cfcatch object">
		<cfthrow object="#arguments.throwObject#">
	</cffunction>
	<!--- Abort Facade --->
	<cffunction name="abortit" access="private" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>

</cfcomponent>