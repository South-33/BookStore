import 'package:flutter/material.dart';
import 'customer_model.dart';
import 'customer_service.dart';

class CustomerForm extends StatefulWidget {
  final Customer? customer; // null means create new, not null means edit

  CustomerForm({this.customer});

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final formKey = GlobalKey<FormState>();
  
  // controllers for text fields
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  CustomerService service = CustomerService();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    
    // if editing, fill the fields with existing data
    if (widget.customer != null) {
      nameController.text = widget.customer!.name;
      emailController.text = widget.customer!.email;
      phoneController.text = widget.customer!.tel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer == null ? "Add Customer" : "Edit Customer"),
        backgroundColor: Colors.blue,
        actions: [
          // show delete button only when editing
          if (widget.customer != null)
            IconButton(
              onPressed: deleteCustomer,
              icon: Icon(Icons.delete),
              color: Colors.red,
            ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    // Name field
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter name';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Email field
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!value.contains('@')) {
                          return 'Invalid email';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Phone field
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Save button
                    ElevatedButton(
                      onPressed: saveCustomer,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(16),
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(
                        widget.customer == null ? 'SAVE' : 'UPDATE',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // function to save or update customer
  void saveCustomer() async {
    // validate form first
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      // create customer object from form data
      Customer customer = Customer(
        id: widget.customer?.id ?? 0,
        name: nameController.text,
        email: emailController.text,
        tel: phoneController.text,
        createdAt: widget.customer?.createdAt ?? '',
        updatedAt: widget.customer?.updatedAt ?? '',
      );

      bool success = false;
      
      // check if creating new or updating
      if (widget.customer == null) {
        // create new
        success = await service.store(customer);
      } else {
        // update existing
        success = await service.update(customer);
      }

      if (success) {
        // show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.customer == null ? 'Customer added!' : 'Customer updated!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // go back and tell previous screen to refresh
        Navigator.pop(context, true);
      }
    } catch (e) {
      // show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      loading = false;
    });
  }

  // function to delete customer
  void deleteCustomer() async {
    // ask for confirmation
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${widget.customer!.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      loading = true;
    });

    try {
      bool success = await service.destroy(widget.customer!.id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer deleted!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      loading = false;
    });
  }
}
