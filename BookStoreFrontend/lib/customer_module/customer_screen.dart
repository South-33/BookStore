import 'package:flutter/material.dart';
import 'customer_form.dart';
import 'customer_model.dart';
import 'customer_service.dart';

class CustomerScreen extends StatefulWidget {
  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  // this will hold the data from api
  late Future<CustomerModel> futureData;
  CustomerService service = CustomerService();
  
  @override
  void initState() {
    super.initState();
    // get data when screen loads
    futureData = service.getData();
  }

  // function to refresh data
  void refreshData() {
    setState(() {
      futureData = service.getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer List"),
        backgroundColor: Colors.blue,
        actions: [
          // add button to create new customer
          IconButton(
            onPressed: () async {
              var result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CustomerForm()),
              );
              
              // refresh if something was saved
              if (result == true) {
                refreshData();
              }
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          refreshData();
        },
        child: FutureBuilder<CustomerModel>(
          future: futureData,
          builder: (context, snapshot) {
            // show loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            
            // show error if failed
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error: ${snapshot.error}"),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: refreshData,
                      child: Text("Try Again"),
                    ),
                  ],
                ),
              );
            }
            
            // show data
            if (snapshot.hasData) {
              var customers = snapshot.data!.data;
              
              return ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  var customer = customers[index];
                  
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      // first letter of name as avatar
                      leading: CircleAvatar(
                        child: Text(customer.name[0]),
                      ),
                      title: Text(customer.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.email, size: 14),
                              SizedBox(width: 5),
                              Text(customer.email),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 14),
                              SizedBox(width: 5),
                              Text(customer.tel),
                            ],
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        // open edit form
                        var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomerForm(customer: customer),
                          ),
                        );
                        
                        if (result == true) {
                          refreshData();
                        }
                      },
                    ),
                  );
                },
              );
            }
            
            return Center(child: Text("No data"));
          },
        ),
      ),
    );
  }
}
