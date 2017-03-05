import Definition, { createAsyncComponent } from 'lanes/screens/definition';
import Group from 'lanes/screens/group';

const isDev = (process.env.NODE_ENV === 'development');

<% Lanes::Screen.each_group do | group | %>
Group.register( <%= group.to_json %> );
<% end %>

const Screens = {};

<% Lanes::Screen.each do | screen | %>
    Screens['<%= screen.identifier %>'] = <%= screen.to_json %>;
    Definition.register(
        Screens['<%= screen.identifier %>'],
        createAsyncComponent({ resolve: () =>
                               System.import(<%= "'#{screen.asset_path}'" %>)
                             })
    );
<% end %>

export default Screens;
