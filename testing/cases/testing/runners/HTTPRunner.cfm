<cfparam name="url.reporter" default="simple">
<cfhttp url="http://cf10cboxdev.jfetmac/coldbox/system/testing/TestBox.cfc" throwonerror="true" redirect="true" result="results">
	<cfhttpparam name="method" value="runRemote" type="URL"/>
	<cfhttpparam name="bundles" value="coldbox.testing.cases.testing.specs.BDDTest" type="URL"/>
	<cfhttpparam name="reporter" value="#url.reporter#" type="URL"/>
</cfhttp>
<cfdump var="#results#">