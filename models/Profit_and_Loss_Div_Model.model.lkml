# Define the database connection to be used for this model.
connection: "prateek_gcp_demo"

# include all the views
include: "/views/**/*.view.lkml"

# Datagroups define a caching policy for an Explore. To learn more,
# use the Quick Help panel on the right to see documentation.

datagroup: Profit_and_Loss_Div_Model_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: Profit_and_Loss_Div_Model_default_datagroup

# Explores allow you to join together different views (database tables) based on the
# relationships between fields. By joining a view into an Explore, you make those
# fields available to users for data analysis.
# Explores should be purpose-built for specific use cases.

# To see the Explore you’re building, navigate to the Explore menu and select an Explore under "Profit and Loss Div Model"

# To create more sophisticated Explores that involve multiple views, you can use the join parameter.
# Typically, join parameters require that you define the join type, join relationship, and a sql_on clause.
# Each joined view also needs to define a primary key.

explore: profit_and_loss {
  from: profit_loss_fact
  label: "Profit and Loss"

  join: customer_dimension {
    type: left_outer
    sql_on: ${profit_and_loss.customer_id} = ${customer_dimension.customer_id} ;;
    relationship: many_to_one
  }

  join: department_dimension {
    type: left_outer
    sql_on: ${profit_and_loss.customer_id} = ${customer_dimension.customer_id} ;;
    relationship: many_to_one
  }

  join: geography_dimension {
    type: left_outer
    sql_on: ${profit_and_loss.geo_id} = ${geography_dimension.geo_id} ;;
    relationship: many_to_one
  }

  join: product_dimension {
    type: left_outer
    sql_on: ${profit_and_loss.product_id} = ${product_dimension.product_id} ;;
    relationship: many_to_one
  }

  join: date_dimension {
    type: left_outer
    sql_on: ${profit_and_loss.date_id} = ${date_dimension.date_id} ;;
    relationship: many_to_one
  }
}
