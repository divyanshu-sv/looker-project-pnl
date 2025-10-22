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

  # --- Requested Measures for Total Values ---

  measure: total_sales {
    type: sum
    sql: ${sales_amount} ;;
    label: "Total Sales"
    value_format: "$#,##0.00"
  }

  measure: total_cost {
    type: sum
    sql: ${cost_amount} ;;
    label: "Total Cost"
    value_format: "$#,##0.00"
  }

  measure: total_profit {
    type: sum
    sql: ${profit_amount} ;;
    label: "Total Profit"
    value_format: "$#,##0.00"
  }

  measure: count {
    type: count
  }

  # --- Dynamic Measure Parameter and Field ---

  parameter: select_metric {
    type: string
    label: "Select Metric"
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

  measure: selected_dynamic_measure {
    type: number
    label: "Selected Dynamic Measure"
    value_format: "$#,##0.00"
    sql:
      CASE
        WHEN {% parameter select_metric %} = 'sales' THEN ${total_sales}
        WHEN {% parameter select_metric %} = 'cost' THEN ${total_cost}
        WHEN {% parameter select_metric %} = 'profit' THEN ${total_profit}
        ELSE NULL
      END
    ;;
  }
# --- [NEW] DYNAMIC DATE GRANULARITY CODE BLOCK ---


# 1. THE PARAMETER (THE FILTER)
parameter: selected_date_granularity {
  type: unquoted
  label: "Select Date Granularity"
  allowed_value: {
    label: "Year"
    value: "year"
  }
  allowed_value: {
    label: "Month"
    value: "month"
  }
  allowed_value: {
    label: "Week"
    value: "week"
  }
  default_value: "month"
}

# 2. THE HIDDEN SORT KEY (THIS FIXES YOUR ERROR)
# This uses your existing ${date_year} field, which returns a
# full date (e.g., 2023-01-01) and WILL NOT cause an error.
dimension: dynamic_date_sort_key {
  hidden: yes
  type: date
  sql:
      {% if selected_date_granularity._parameter_value == 'year' %}
        ${date_year}
      {% elsif selected_date_granularity._parameter_value == 'month' %}
        ${date_month}
      {% elsif selected_date_granularity._parameter_value == 'week' %}
        ${date_week}
      {% else %}
        ${date_month}
      {% endif %}
    ;;
}

# 3. THE VISIBLE DIMENSION (FOR YOUR CHART'S X-AXIS)
# This creates the clean *string label* (e.g., "2023").
dimension: dynamic_date_dimension {
  label_from_parameter: selected_date_granularity
  type: string
  sql:
      {% if selected_date_granularity._parameter_value == 'year' %}
        FORMAT_DATE("%Y", ${date_date})
      {% elsif selected_date_granularity._parameter_value == 'month' %}
        FORMAT_DATE("%Y-%m", ${date_date})
      {% elsif selected_date_granularity._parameter_value == 'week' %}
        FORMAT_DATE("%Y-%m-%d", ${date_week})
      {% else %}
        FORMAT_DATE("%Y-%m", ${date_date})
      {% endif %}
    ;;
    # This sorts the string label by the hidden, correct date field.
    order_by_field: dynamic_date_sort_key
  }

  # --- END OF DYNAMIC DATE CODE BLOCK ---
  }
