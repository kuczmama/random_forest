# Random Forest

Create a random forest with ruby

## Usage:

```
Usage: ./random_forest.rb TRAINING_DATA.csv [options]
    -m, --max-input-size=ROWS        Max rows to read in from the TRAINING_DATA csv, default read in all rows
    -h, --help                       Prints this help
    -v, --verbose                    Run verbosely
    -l, --label=LABEL                The column name that is the dependent variable. Default 'label'
    -nNUM_TREES,                     Number of decision trees in the random forest
        --num-decision-trees
```

## Example Usage

```
./random_forest.rb train.csv -m 1000 -v -n 5
```
Creates a random forest from `train.csv`
- `-m` Read `1000` lines of input data.  
- `-v` In verbose mode.
- `-n` with 5 trees in the forest
