## Data Capture and compare

#### Getting started!

1. Create an `endpoints.txt` file with then endpoints that you wish to run against.  ie `/reports/123?USER_ID=45`
2. Copy the test.properties template

        cp test.yaml.template test.yaml

3. Set the values for your two servers to compare in `test.properties`
4. Install dependent gems

        bundle

5. Run the script!

        ruby run.rb

#### Results!

You can see your results in `/results/results.diff`. We only show results if there are differences
