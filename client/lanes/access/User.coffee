class Lanes.Models.User extends Lanes.Models.Base

    constructor: (attributes, access) ->
        super
        this.access_data = access

    api_path: -> '/lanes-access/users'
    derived:
        roles:
            deps: ['role_names', 'access_data']
            fn: -> new Lanes.Models.UserRoleSet( @access_data )
        isLoggedIn:
            deps:['id'], fn: -> !!this.id
        allRoles:
            deps: ['role_names', 'access_data']
            fn: ->
                role_data = Lanes.Models.Role.all?.toJSON() || []
                roles = new Lanes.Models.Role.Collection( role_data )
                _.each( this.role_names, (name) ->
                    roles.get(name)?.member = true
                )
                roles

    session:
        access_data: 'object'

    props:
        id:          'integer'
        login:       'string'
        name:        'string'
        email:       'string'
        role_names: { type: 'array', default: -> [] }
        options:     'object'
        password:    'string'

    hasAccess: (access, model, field) -> this.roles.can(access, model, field)
    canRead: (model, field)  -> this.roles.canRead(model, field)
    canWrite: (model, field) -> this.roles.canWrite(model, field)
    canDelete: (model)       -> this.roles.canDelete(model)

    logout: ->
        return unless @isLoggedIn
        session = new Session( id: this.id )
        session
            .destroy()
            .then =>
                @access_data = []
                @role_names  = []
                _.each(@attributes, (value, key) => @set(key, null) )

    setLoginData: (attrs, access) ->
        this.access_data = access
        this.set(attrs)

    @attemptLogin: (login, password, options) ->
        session = new Session( login: login, password: password )
        success = options.success
        session.save(_.extend(options, {
            success: (reply) ->
                Lanes.current_user.setLoginData(session.user, session.access)
                success.apply(options.scope, arguments)
        }))
        session


class Session extends Lanes.Models.Base
    api_path: '/lanes-access/user-session'
    props:
        id:         'integer'
        login:      'string'
        password:   'string'
        access:     'object'
        user:       'object'
