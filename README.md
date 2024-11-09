StylePos-API
===========================

A StylePos API designed specifically for clothing retail stores. The API provides a comprehensive solution for managing sales, inventory, and customer information. It offers a user-friendly interface and incorporates features tailored to the unique needs of clothing retailers

## Key Features:
- Real-time Sales Data: Retrieve sales transaction data as it happens, providing up-to-the-minute information on items sold, quantities, prices, and total revenue generated.
- Transaction Notifications: Receive instant notifications or webhook callbacks whenever a sales transaction occurs, allowing for immediate updates and triggers in connected applications.
- Integrated Barcode Scanning: Seamlessly integrate with barcode scanners to scan and manage clothing items, improving efficiency at the point of sale and inventory management.
- Performance Metrics: Access key performance metrics, such as total sales, average transaction value, top-selling items, and sales trends, to gain insights into business performance.
- Filter and Search Capabilities: Apply filters and search parameters to retrieve sales data based on specific criteria, such as time range, or product categories.
- Authentication and Security: Implement secure authentication mechanisms, such as API keys or OAuth, to ensure authorized access to the live sales tracking API.
- Scalability and Reliability: Build upon a scalable and reliable infrastructure that can handle high transaction volumes and deliver real-time data with minimal latency.


## Requirements
The following are required to run the Clothing Retail Stores API: 

- Ruby 3.1+
- Rails 7.0+
- PostgreSql
- Redis

## Getting Started

1. Clone the repo

   ```
   $ git clone https://github.com/Bright-Phiri/StylePos-API.git
   $ cd StylePos-API
   ```

2. Install dependencies

   ```
   $ bundle install
   ```
3. Create database:

   ```
   $ bin/rails db:create
   ```

4. Run migrations:

   ```
   $ bin/rails db:migrate
   ```
   
5. Running the API

   ```
   $ bin/rails server
   ```


### Dealing with Missing `master.key` (Credentials Issue)
If you encounter an error like "Couldn't decrypt config/credentials.yml.enc," it indicates that the `master.key` file, which is used to decrypt the credentials, is missing.

To resolve this issue, follow these steps:

1. **Remove the existing `credentials.yml.enc`:**

2. **Recreate the credentials file:**

Run the following command to generate a new `credentials.yml.enc` file:

$ bin/rails credentials:edit
This will open an editor to create new credentials.
## Contributing:
- Contributions to the project are welcome! If you find any issues or have suggestions for improvements, please submit a pull request or open an issue in the repository. 

 ## Contributors 
 - [Bright](https://www.github.com/Bright-Phiri) - creator and maintainer
