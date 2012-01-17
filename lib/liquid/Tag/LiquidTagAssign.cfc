<cfcomponent output="false" extends="liquid.LiquidTag" hint="
Performs an assignment of one variable to another
{%assign var = var %}
{%assign var = "hello" | upcase %}
">

	<cffunction name="init">
		<cfargument name="markup" type="string" required="true">
		<cfargument name="tokens" type="array" required="true">
		<cfargument name="file_system" type="any" required="true">
		<cfset var loc = {}>
		
		<cfset loc.syntax_regexp = createobject("component", "liquid.LiquidRegexp").init('(\w+)\s*=\s*(#application.LiquidConfig.LIQUID_QUOTED_FRAGMENT#+)')>

		<cfset loc.filter_seperator_regexp = createobject("component", "liquid.LiquidRegexp").init('#application.LiquidConfig.LIQUID_FILTER_SEPARATOR#\s*(.*)')>
		<cfset loc.filter_split_regexp =createobject("component", "liquid.LiquidRegexp").init('#application.LiquidConfig.LIQUID_FILTER_SEPARATOR#')>
		<cfset loc.filter_name_regexp = createobject("component", "liquid.LiquidRegexp").init('\s*(\w+)')>
		<cfset loc.filter_argument_regexp = createobject("component", "liquid.LiquidRegexp").init('(?:#application.LiquidConfig.LIQUID_FILTER_ARGUMENT_SEPARATOR.'|'application.LiquidConfig.LIQUID_ARGUMENT_SEPARATOR.')\s*('application.LiquidConfig.LIQUID_QUOTED_FRAGMENT#)')>

		<cfset this.filters = []>

		<cfif loc.filter_seperator_regexp.match(arguments.markup)>
			
			<cfset loc.filters = loc.filter_split_regexp.split(loc.filter_seperator_regexp.matches[1])>

			<cfloop array="#loc.filters#" index="loc.filter">
				<cfset loc.filter_name_regexp.match(loc.filter)>
				<cfset loc.filtername = loc.filter_name_regexp.matches[1]>

				<cfset filter_argument_regexp.match_all(arguments.filter)>
				<cfset loc.matches = array_flatten(loc.filter_argument_regexp.matches[1])>
				
				<cfset loc.temp = [loc.filtername, loc.matches]>
				<cfset arrayAppend(this.filters, loc.temp)>
			</cfloop>
		</cfif>

		<cfif loc.syntax_regexp.match($markup)>
			<cfset this._to = loc.syntax_regexp.matches[1]>
			<cfset this._from = loc.syntax_regexp.matches[2]>
		<cfelse>
			<cfthrow type="LiquidError" message="Syntax Error in 'assign' - Valid syntax: assign [var] = [source]">
		</cfif>
		
		<cfreturn this>
	</cffunction>


	<cffunction name="render" hint="Renders the tag">
		<cfargument name="context" type="any" required="true">
		<cfset var loc = {}>
		<cfset loc.output = arguments.context.get(this._from)>

		<cfloop array="#this.filters#" index="loc.filter">
			
			<cfset loc.filtername = loc.filter[1]>
			<cfset loc.filter_arg_keys = loc.filter[2]>

			<cfset loc.filter_arg_values = []>

			<cfloop array="#loc.filter_arg_values#" index="loc.arg_key">
				<cfset arrayAppend(loc.filter_arg_values, arguments.context.get(loc.arg_key))>
			</cfloop>

			<cfset loc.output = argumentscontext.invoke_method(loc.filtername, loc.output, loc.filter_arg_values)>
		</cfloop>

		<cfset arguments.context.set(this._to, loc.output)>
	</cffunction>
	
</cfcomponent>