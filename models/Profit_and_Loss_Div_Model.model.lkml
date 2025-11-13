# Define the database connection to be used for this model.

connection: "prateek_gcp_demo"

# include all the views
# This wildcard will automatically pick up your new view
# as long as it's in the /views/ folder.
include: "/views/**/*.view.lkml"

# Datagroups define a caching policy for an Explore. To learn more,
# use the Quick Help panel on the right to see documentation.

datagroup: Profit_and_Loss_Div_Model_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: Profit_and_Loss_Div_Model_default_datagroup

# This is your original, main explore.
# We leave this untouched.
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
    sql_on: ${profit_and_loss.dept_id} = ${department_dimension.dept_id} ;;
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

# --- 🌟 1. ADD THIS NEW EXPLORE BLOCK 🌟 ---
#
# This creates a new, separate "Explore" in the Looker menu
# that is purpose-built for your custom subtotal report.

explore: pl_custom_report {
  # This 'explore' starts FROM your new view
  from: pl_with_custom_subtotals

  # This is the name users will see in the Explore menu
  label: "P&L Custom Subtotal Report"
  description: "A special report showing SUM(Sales) for products and AVG(Sales) for department subtorals."

  # We join 'department_dimension' so users can
  # select the department name, region, etc.
  join: department_dimension {
    type: left_outer
    sql_on: ${pl_custom_report.dept_id} = ${department_dimension.dept_id} ;;
    relationship: many_to_one
  }
}
