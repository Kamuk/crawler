##############################################################################
#	
##############################################################################

@CLASS
ActiveModel

@OPTIONS
locals
partial



##############################################################################
@static:GET_CACHE_ENABLED[]
	$result($self.META.CACHE_ENABLED && $self.GLOBAL_CACHE_ENABLED)
#end @GET_CACHE_ENABLED[]



##############################################################################
@static:SET_CACHE_ENABLED[bValue]
	$self.META.CACHE_ENABLED($bValue)
#end @SET_CACHE_ENABLED[]



##############################################################################
#	TODO: deprecated
@static:GET_model_cache[]
	^throw_inspect[deprecated]
	$result[$self.META.model_cache]
#end @GET_model_cache[]



##############################################################################
@static:GET_MODEL_CACHE[]
	$result[$self.META.model_cache]
#end @GET_MODEL_CACHE[]



##############################################################################
#	TODO: deprecated
@static:GET__validators[]
	$result[$self.META.validators]
#end @GET__validators[]



##############################################################################
@static:GET_VALIDATORS[]
	$result[$self.META.validators]
#end @static:GET_VALIDATORS[]



##############################################################################
#	TODO: deprecated
@static:GET_fields[]
	^throw_inspect[deprecated]
	$result[$self.META.fields]
#end @GET_fields[]



##############################################################################
#	Возвращает мета информацию о аттрибутах модели
##############################################################################
@static:GET_FIELDS[]
	$result[$self.META.fields]
#end @static:GET_FIELDS[]



##############################################################################
#	TODO: deprecated
@static:GET_fields_accessor[]
	^throw_inspect[deprecated]
	$result[$self.META.fields_accessor]
#end @GET_fields_accessor[]



##############################################################################
#	Возвращает информацию об ассесорах
##############################################################################
@static:GET_ACCESSORS[]
	$result[$self.META.fields_accessor]
#end @static:GET_ACCESSORS[]




##############################################################################
#	Возвращает мета информацию о scopes
##############################################################################
@static:GET_SCOPES[]
	$result[$self.META.scopes]
#end @static:GET_SCOPES[]



##############################################################################
#	Возвращает мета информацию о scopes_with
##############################################################################
@static:GET_SCOPES_WITH[]
	$result[$self.META.scopes_with]
#end @static:GET_SCOPES_WITH[]



##############################################################################
#	TODO: deprecated
@static:GET__association[]
	^throw_inspect[deprecated]
	$result[$self.META.association]
#end @GET__association[]



##############################################################################
#	Возвращает мета информацию об ассоциациях
##############################################################################
@static:GET_ASSOCIATIONS[]
	$result[$self.META.association]
#end @static:GET_ASSOCIATIONS[]



##############################################################################
#	Возвращает ассоциации модели
##############################################################################
@GET_associations[]
	$result[$self._associations_values]
#end @GET_associations_values[]



##############################################################################
#	Возвращает мета информацию о вложенных ассоциациях
##############################################################################
@static:GET_NESTED_ATTRIBUTES_FOR[]
	$result[$self.META.nested_attributes_for]
#end @static:GET_NESTED_ATTRIBUTES_FOR[]



##############################################################################
#	TODO: deprecated
@static:GET_attached_files_meta[]
	^throw_inspect[deprecated]
	$result[$self.META.attached_files_meta]
#end @GET_attached_files_meta[]



##############################################################################
@static:GET_ATTACHED_FILES[]
	$result[$self.META.attached_files_meta]
#end @static:GET_ATTACHED_FILES[]



##############################################################################
#	Возвращает связанные файлы модели
##############################################################################
@GET_attached_files[]
	$result[$self._attached_files]
#end @GET_attached_files[]
