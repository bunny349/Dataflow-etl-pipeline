# PipelineViz 📊

> A data engineering pipeline: messy synthetic e-commerce order data → cleaned, transformed, and orchestrated with **Prefect** → served as KPIs via **FastAPI** → visualized in a live dashboard with Chart.js.

![CI](https://github.com/YOUR_USERNAME/pipelineviz/actions/workflows/ci.yml/badge.svg)
![Python](https://img.shields.io/badge/python-3.12-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## What this demonstrates

Real-world data is messy. This project generates synthetic e-commerce orders with intentional real-world problems — duplicate rows, null values, inconsistent category casing (`"Electronics"` / `"ELECTRONICS "` / `" electronics"`), and mixed date formats — then runs a proper ETL pipeline to clean and aggregate it:

- **Extract** — load raw CSV
- **Transform** — deduplicate, normalize strings, parse mixed date formats, drop unusable rows, compute derived columns
- **Load** — compute KPI datasets (revenue by category/region, monthly trend, top products) and persist as JSON

Orchestrated with **Prefect** (retries, logging, and run history for free), served via a **FastAPI** REST API, and visualized in a dark-themed dashboard with live charts.

## Architecture

```
pipelineviz/
├── pipeline/
│   ├── generate_data.py   # synthetic messy data generator
│   ├── transform.py       # pure, unit-tested cleaning/aggregation functions
│   └── flow.py             # Prefect flow orchestrating extract → clean → transform → load
├── api/
│   └── main.py             # FastAPI serving KPIs as JSON + triggers pipeline runs
├── frontend/
│   ├── index.html
│   ├── style.css
│   └── app.js               # Chart.js dashboard
├── tests/
│   ├── test_transform.py   # 13 tests — cleaning/aggregation correctness
│   └── test_api.py          # 4 tests — API endpoints
├── Dockerfile
└── .github/workflows/ci.yml
```

## Quick Start

```bash
pip install -r requirements.txt

# Generate synthetic raw data
python pipeline/generate_data.py

# Run the pipeline (cleans data, computes KPIs, writes data/kpis.json)
python -m pipeline.flow

# Start the dashboard
uvicorn api.main:app --reload
```

Visit `http://localhost:8000` for the dashboard, or `http://localhost:8000/docs` for the interactive API docs.

### Docker

```bash
docker build -t pipelineviz .
docker run -p 8000:8000 pipelineviz
```

## Running Tests

```bash
python pipeline/generate_data.py && python -m pipeline.flow  # produces test fixtures
pytest tests/ -v
```

## Example Output

Cleaning 2,060 raw rows (with ~3% injected duplicates and ~2% injected nulls) reliably produces:

```json
{
  "total_orders": 1960,
  "total_revenue": 741281.64,
  "avg_order_value": 378.2,
  "unique_customers": 396
}
```

## Design Notes

- **Why separate `transform.py` from `flow.py`?** Every transformation is a pure function (`DataFrame in → DataFrame/dict out`), independently unit-testable without spinning up Prefect at all. `flow.py` is a thin orchestration layer wrapping those functions in `@task`/`@flow` decorators for retries, logging, and observability.
- **Why Prefect over Airflow?** Prefect runs as plain Python with no separate scheduler/webserver infrastructure required — appropriate for a project this size. The same `transform.py` functions would drop into an Airflow DAG with minimal changes if you needed Airflow's scheduling model instead.

## Roadmap

- [ ] Scheduled runs (Prefect deployments + a work pool)
- [ ] Swap synthetic CSV for a real data source (S3, a database)
- [ ] Data quality checks as a pipeline stage (e.g. with Great Expectations)
- [ ] Persist KPI history over time instead of overwriting `kpis.json`

## License

MIT — see [LICENSE](LICENSE).
