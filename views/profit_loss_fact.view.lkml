# The name of this view in Looker is "Profit Loss Fact"
view: profit_loss_fact {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `Profit_and_Loss_Dataset.Profit_Loss_Fact` ;;

  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

    # Here's what a typical dimension looks like in LookML.
    # A dimension is a groupable field that can be used to filter query results.
    # This dimension will be called "Cost Amount" in Explore.

  dimension: cost_amount {
    type: number
    sql: ${TABLE}.cost_amount ;;
  }

  dimension: customer_id {
    type: number
    sql: ${TABLE}.customer_id ;;
  }
  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date ;;
  }

  dimension: date_id {
    type: number
    sql: ${TABLE}.date_id ;;
  }

  dimension: dept_id {
    type: number
    sql: ${TABLE}.dept_id ;;
  }

  dimension: geo_id {
    type: number
    sql: ${TABLE}.geo_id ;;
  }

  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
  }

  dimension: profit_amount {
    type: number
    sql: ${TABLE}.profit_amount ;;
  }

  dimension: sales_amount {
    type: number
    sql: ${TABLE}.sales_amount ;;
  }

  dimension: transaction_id {
    type: number
    sql: ${TABLE}.transaction_id ;;
  }

# --- >>> STEP 1: CREATE BASE MEASURES (HIDDEN) ---
  # Create SUMs for your numeric dimensions.
  # We hide them so users are encouraged to use the dynamic measure.

  measure: total_sales {
    type: sum
    sql: ${sales_amount} ;; # References the dimension
    value_format_name: usd_0
    hidden: yes
  }

  measure: total_cost {
    type: sum
    sql: ${cost_amount} ;; # References the dimension
    value_format_name: usd_0
    hidden: yes
  }

  measure: total_profit {
    type: sum
    sql: ${profit_amount} ;; # References the dimension
    value_format_name: usd_0
    hidden: yes
  }

  # --- >>> STEP 2: CREATE THE PARAMETER ---
  # This will create the filter dropdown in the Explore.

  parameter: selected_metric_parameter {
    type: unquoted
    label: "Select Metric"
    default_value: "sales" # This is the metric that will show by default
    allowed_value: {
      label: "Sales"
      value: "sales"
    }
    allowed_value: {
      label: "Cost"
      value: "cost"
    }
    allowed_value: {
      label: "Profit"
      value: "profit"
    }
  }

  # --- >>> STEP 3: CREATE THE DYNAMIC MEASURE ---
  # This is the single measure users will add to their report.
  # It uses Liquid to change its value and label.

      measure: selected_metric {
        # The label dynamically changes
        label: "{% if selected_metric_parameter._parameter_value == 'sales' %}
        Total Sales
        {% elsif selected_metric_parameter._parameter_value == 'cost' %}
        Total Cost
        {% elsif selected_metric_parameter._parameter_value == 'profit' %}
        Total Profit
        {% else %}
        Total Sales
        {% endif %}"

        type: number
        value_format_name: usd_0

        # The sql block dynamically switches which measure to show
        sql:
              {% if selected_metric_parameter._parameter_value == 'sales' %}
                ${total_sales}
              {% elsif selected_metric_parameter._parameter_value == 'cost' %}
                ${total_cost}
              {% elsif selected_metric_parameter._parameter_value == 'profit' %}
                ${total_profit}
              {% else %}
                ${total_sales}  -- Default to sales
              {% endif %}
              ;;
      }
  measure: count {
    type: count
  }
}
