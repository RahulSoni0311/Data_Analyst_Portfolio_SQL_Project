# SQL Data Warehouse Project

## Overview

This project demonstrates the development of an end-to-end SQL Data Warehouse
using MySQL.

The warehouse integrates data from CRM and ERP source systems and processes
it through Bronze, Silver, and Gold layers to produce business-ready data
for reporting and analytics.

## Project Goals

- Build an end-to-end SQL Data Warehouse.
- Integrate CRM and ERP source data.
- Clean and standardize data through layered transformations.
- Create business-ready dimension and fact views.
- Implement data quality checks.

## Architecture

The warehouse follows a layered architecture consisting of Bronze, Silver,
and Gold layers.

![Data Architecture](Data_Analyst_Portfolio_SQL_Project/Docs
/data_architechture.png)

## Data Sources

- **CRM:** Customer, product, and sales information.
- **ERP:** Customer demographic, location, and product category information.

## Data Warehouse Layers

| Layer | Description |
|---|---|
| Bronze | Stores raw data from CRM and ERP source files. |
| Silver | Cleans, standardizes, and transforms the raw data. |
| Gold | Provides business-ready dimension and fact views. |

## Data Integration

CRM and ERP data is integrated to create a unified business view.

Key integration activities include:

- Customer information integration
- Customer location integration
- Product and category integration
- Source-priority rules for overlapping information
- Linking sales transactions to customer and product dimensions

## Data Quality

Quality checks are performed across the warehouse layers to identify:

- Duplicate records
- Missing values
- Invalid dates
- Invalid identifiers
- Data standardization issues
- Referential integrity issues

## Project Structure

```text
Data_Analyst_Portfolio_SQL_Project/
├── Datasets/
├── Docs/
├── Investigation/
├── Scripts/
│   ├── Bronze/
│   ├── Silver/
│   └── Gold/
├── tests/
├── README.md
└── LICENSE
