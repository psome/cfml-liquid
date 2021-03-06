<cfset this.filters = "">

<cffunction name="arrayCompare" returntype="boolean">
	<cfargument name="LeftArray" type="array" required="true">
	<cfargument name="RightArray" type="array" required="true">
	<cfset var loc = {}>
	<cfset loc.results = true>

	<cfif !isArray(arguments.LeftArray) OR !isArray(arguments.RightArray)>
		<cfreturn false>
	</cfif>
    
	<cfif arrayLen(arguments.LeftArray) neq arrayLen(arguments.RightArray)>
		<cfreturn false>
	</cfif>
    
	<!--- Loop through the elements and compare them one at a time --->
	<cfloop from="1" to="#ArrayLen(arguments.LeftArray)#" index="loc.i">
        <!--- elements is a structure --->
		<cfif isStruct(arguments.LeftArray[loc.i])>
			<cfset loc.temp1 = arguments.LeftArray[loc.i]>
			<cfset loc.temp2 = arguments.RightArray[loc.i]>
			<cfset loc.result = loc.temp1.Equals(loc.temp2)>
            <cfif NOT loc.result>
				<cfreturn false>
			</cfif>
		<!--- elements is an array, call arrayCompare() --->
        <cfelseif isArray(LeftArray[loc.i])>
            <cfset loc.result = arrayCompare(arguments.LeftArray[loc.i],arguments.RightArray[loc.i])>
            <cfif NOT loc.result>
				<cfreturn false>
			</cfif>
		<!--- A simple type comparison here --->
		<cfelse>
            <cfif arguments.LeftArray[loc.i] IS NOT arguments.RightArray[loc.i]>
				<cfreturn false>
			</cfif>
		</cfif>
	</cfloop>
    <cfreturn true>
</cffunction>

<cffunction name="arrayWrap">
	<cfargument name="value" type="any" required="true">
	<cfset var ret = [arguments.value]>
	<cfreturn ret>
</cffunction>

<cffunction name="assert_template_result">
	<cfargument name="expected" type="string" required="true">
	<cfargument name="template" type="string" required="true">
	<cfargument name="templateObj" type="any" required="true">
	<cfargument name="assigns" type="struct" required="false" default="#StructNew()#">

		<cfset loc.e = arguments.expected>
		<cfset arguments.templateObj.parse(arguments.template)>

		<cfset loc.r = arguments.templateObj.render(arguments.assigns, this.filters)>
		<cfset loc.result = CompareNoCase(loc.e, loc.r)>
		
		<cfif loc.result neq 0>
			<cfset this.debug('loc')>
		</cfif>
		
		<cfset this.assert('loc.result eq 0')>
</cffunction>
	
<cffunction name="getClassName">
	<cfargument name="obj" type="any" required="true">
	<cfif IsObject(arguments.obj)>
		<cfreturn ListLast(getMetaData(arguments.obj).name, ".")>
	</cfif>
	<cfreturn "">
</cffunction>