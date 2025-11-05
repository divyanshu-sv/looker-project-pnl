# This file is product_daily_summary_pdt.view.lkml


view: product_daily_summary_pdt {

  # This derived_table block defines the PDT
  derived_table: {
    # This is the SQL query that builds your new table
    sql:
      SELECT
        f.date AS order_date,
        p.product_id AS product_id,
        p.product_name AS product_name,
        p.category AS category,
        p.brand AS brand,
        SUM(f.sales_amount) AS pdt_total_sales,
        SUM(f.cost_amount) AS pdt_total_cost,
        SUM(f.profit_amount) AS pdt_total_profit,
        COUNT(f.transaction_id) AS pdt_order_count
      FROM
        ${profit_loss_fact.SQL_TABLE_NAME} AS f
      LEFT JOIN
        ${product_dimension.SQL_TABLE_NAME} AS p
          ON f.product_id = p.product_id
      GROUP BY 1, 2, 3, 4, 5
      ;;

    # This 'datagroup_trigger' tells the PDT when to rebuild.
    # 'your_datagroup_name' would be defined in your model file
    # (e.g., set to trigger every 24 hours).
    datagroup_trigger: your_datagroup_name
  }

  # --- Dimensions ---
  # Define dimensions for each column in your SELECT query

  dimension_group: order_date {
    primary_key: yes
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}.order_date ;;
  }

  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
  }

  dimension: product_name {
    type: string
    sql: ${TABLE}.product_name ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
  }

  # --- Measures ---
  # Create measures that aggregate the pre-aggregated columns from your PDT

  measure: total_sales {
    type: sum
    sql: ${TABLE}.pdt_total_sales ;;
    value_format: "$#,##0.00"
  }

  measure: total_cost {
    type: sum
    sql: ${TABLE}.pdt_total_cost ;;
    value_format: "$#,##0.00"
  }

  measure: total_profit {
    type: sum
    sql: ${TABLE}.pdt_total_profit ;;
    value_format: "$#,##0.00"
  }

  measure: total_orders {
    type: sum
    sql: ${TABLE}.pdt_order_count ;;
  }

}
