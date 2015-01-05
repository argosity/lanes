---
title: TODO MVC Example
position_after: command
---

As is required by all new frameworks, this is an example of creating a TODO application using the Lanes framework.

First install Lanes via Rubygems.  `gem install lanes`

As always when using Lanes, the first thing you'll need to do is generate your application.  We will name this app simply as `todo`

{% highlight bash %}
lanes new todo
{% endhighlight %}

This will create a new directory with a skeleton Lanes application.  Read more about the directories and what their purposes are at {% doc_link command heading:'lanes new' %}.

[Our example app at this point](https://github.com/argosity/lanes-todo-demo/tree/2d649b314a826cbbdbf54e3f72041caeeee8e428)

# Setup

A sample database configuration file is located in `config/database.yml` which will use a postgresql database named todo_dev.  For the purposes of this example, we'll just create a new postgresql database that matches the configuration: `createdb todo_dev`

Fire up the lanes testing server: `lanes serve`.  The test server will start the app and you can view it at: `http://localhost:8888/`.   You should see a simple "Todo" message.  You can also view the Jasmine specs at `http://localhost:8888/spec`

We'll copy the styles from the [TodoMVC template](https://github.com/tastejs/todomvc/tree/master/template).

Looking at the Todo app, it has four distinct areas. A `sidebar`, `header`, `footer` and `listing` views. We can create views for them by executing `lanes generate view <name>`, where '< name >' is the view to create. [commit](https://github.com/argosity/lanes-todo-demo/commit/758d0e63359db18ee0291467656454c9fc1c3573)

First we take the TodoMVC html template and break it apart into sections and copy them to each view.  We're then able to plug each view's reference into the Screen as subviews. [commit](https://github.com/argosity/lanes-todo-demo/commit/8c5178a76f2a8abc0ffadbafb1239f7a8ba113b9)

Next we'll create a data model `lanes generate model task title:string{80} completed:boolean` [commit](https://github.com/argosity/lanes-todo-demo/commit/5080c286aa4fb35a2b8372cc86ca4e9e18a18c3f)

Since a task should default to being non-completed, we'll edit the migration to default that field to `false` and add a validation to the model [commit](https://github.com/argosity/lanes-todo-demo/commit/e3f7edf9f2863f0669cccac13f7f8e2b88276b5a)

Run migration: `lanes db migrate`

We'll also create a TaskSummary model that is in charge of summarizing the state of the tasks.  It will listen to the tasks collection and perform calculations when events occur. [commit](https://github.com/argosity/lanes-todo-demo/commit/65da191ee749ab749855e06ce69c3bd09662e0d5)

# Data and events

## Header View
It's responsible for interaction with the "What needs to be done?" input.  When text is present and the "enter" key is pressed, it should save a record and add it to the collection.  We're able to do so in [just a few lines of code](https://github.com/argosity/lanes-todo-demo/blob/master/client/todo/views/Header.coffee#L22-L25)

We can easily test that it performs as it should by [adding a few specs](https://github.com/argosity/lanes-todo-demo/blob/master/spec/todo/views/HeaderSpec.coffee#L18-L29). 

## Listing View
This view is a bit more complex.  It has a parent view which handles toggling all todo's between being complete and pending, and a collection of subviews that model each individual task. [ListingView](https://github.com/argosity/lanes-todo-demo/blob/master/client/todo/views/Listing.coffee)

Each TaskView is responsible for handling it's own editing state and saving value to it's model.

## Footer View
The only action this view takes is to delete any tasks that are marked as complete when the "Clear Completed" button is clicked.  It also displays quite a few values from our TasksSummary.  Lane's declarative bindings make these easy to wire up. [FooterView](https://github.com/argosity/lanes-todo-demo/blob/master/client/todo/views/Footer.coffee)

You might notice that Lanes makes it super easy to batch update or delete a collection.  The footer simply calls destroyAll on the "completed" sub-collection provided by the TaskSummary.  Since that sub-collection filters the main collection to only contain "completed" tasks, it's safe to just destroy all the model's in one go.  It's so easy in fact that the FooterView demonstrates an alternative use of events.  The function is directly given to the "events" property, rather than a method reference. [Save Call](https://github.com/argosity/lanes-todo-demo/blob/master/client/todo/views/Footer.coffee#L27)

# Routing

For a simple app like the this one, it's easiest to just allow the URL change to trigger what the filtered collection is displaying.  We set that up when the screen is initialized. [Routing](https://github.com/argosity/lanes-todo-demo/blob/master/client/todo/Router.coffee)

# Deploying

For the example we'll host it on Heroku.  Other deployments should be similar to deploying a Rails application.

Simply commit the source and add a remote per Heroku's instructions: [https://devcenter.heroku.com/articles/git](https://devcenter.heroku.com/articles/git)

When you `git push heroku`, Heroku will notice that Lanes uses sprockets and will automatically run `rake assets:precompile`, and then run the application using the puma webserver.

On first deploy and when your db schema has changed, you will have to provision and migrate the database on Heroku by running: `heroku run rake db:migrate`

