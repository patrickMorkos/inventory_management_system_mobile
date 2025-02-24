import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_system_mobile/core/controllers/client_controller.dart';
import 'package:inventory_management_system_mobile/core/controllers/logged_in_user_controller.dart';
import 'package:inventory_management_system_mobile/data/api_service.dart';
import 'package:inventory_management_system_mobile/view/widgets/button_global.dart';
import 'package:inventory_management_system_mobile/core/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:image_picker/image_picker.dart';

class CreateNewClientScreen extends StatefulWidget {
  const CreateNewClientScreen({super.key});

  @override
  State<CreateNewClientScreen> createState() => _CreateNewClientScreenState();
}

// Variable to hold the selected file type (Image or Document)
enum FileTypeOption { image, document }

class _CreateNewClientScreenState extends State<CreateNewClientScreen> {
  //******************************************************************VARIABLES
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController commercialRegisterController = TextEditingController();
  TextEditingController mofNumberController = TextEditingController();
  TextEditingController vatRegisterController = TextEditingController();

  String selectedLocationArea = "1"; // Default to first location
  List<dynamic> locationAreas = [];
  String? selectedPriceClass;
  List<String> priceClasses = [
    "None",
    "a1",
    "a2",
    "b1",
    "b2",
    "c1",
    "c2",
    "d1",
    "d2"
  ];

  // Initial file type for Izaa Tijariye and Photocopy ID
  FileTypeOption _selectedFileTypeIzaa = FileTypeOption.document;
  FileTypeOption _selectedFileTypePhotocopy = FileTypeOption.document;

  // For File Pickers
  File? izaaTijariyePdf;
  File? photocopyIdCardPdf;

  // Flag to choose image or file for Izaa Tijariye
  bool isImageFileIzaa = false;

  // Flag to choose image or file for Photocopy ID Card
  bool isImageFilePhotocopy = false;

  // Form key for validation
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //This variable is the logged in user controller
  final LoggedInUserController loggedInUserController =
      Get.put(LoggedInUserController());

  //******************************************************************FUNCTIONS

  Future<void> getLocationAreas() async {
    var response = await getRequest(
        path: "/api/client/get-location-areas", requireToken: true);
    setState(() {
      locationAreas = response;
    });
  }

  // Function to pick a file for Izaa Tijariye PDF or Image
  Future<void> selectFileForIzaaTijariyePdf() async {
    if (_selectedFileTypeIzaa == FileTypeOption.image) {
      // Open the camera to capture an image
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          izaaTijariyePdf =
              File(pickedFile.path); // Assign the selected image file
        });
      }
    } else {
      // Otherwise, use the FilePicker to select a PDF file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        setState(() {
          izaaTijariyePdf = File(result.files.single.path!);
        });
      }
    }
  }

// Function to pick a file for Photocopy ID Card or Image
  Future<void> selectFileForPhotocopyIdCardPdf() async {
    if (_selectedFileTypePhotocopy == FileTypeOption.image) {
      // Open the camera to capture an image
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          photocopyIdCardPdf =
              File(pickedFile.path); // Assign the selected image file
        });
      }
    } else {
      // Otherwise, use the FilePicker to select a PDF file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        setState(() {
          photocopyIdCardPdf = File(result.files.single.path!);
        });
      }
    }
  }

  // This function handles the API call for creating a new client with files
  Future<void> createClient() async {
    if (formKey.currentState!.validate()) {
      Map<String, String> body = {
        "first_name": firstNameController.text,
        "last_name": lastNameController.text,
        "phone_number": phoneNumberController.text,
        "address": addressController.text,
        "company_name": companyNameController.text,
        "commercial_register": commercialRegisterController.text,
        "mof_number": mofNumberController.text,
        "vat_register": vatRegisterController.text,
        "location_area_id": selectedLocationArea,
        if (selectedPriceClass != null) "price_class": selectedPriceClass!,
        "qr_code": "test" // Fixed qr_code
      };

      Map<String, File?> files = {
        "izaa_tijariye_pdf_url": izaaTijariyePdf,
        "photocopy_id_card_url": photocopyIdCardPdf,
      };

      try {
        var response = await postRequestWithFiles(
          path:
              "/api/client/create-client/${loggedInUserController.loggedInUser.value.id}",
          data: body,
          files: files,
          requireToken: true,
        );
        if (response['error'] == null) {
          // Successfully created the client, extract client ID
          int newClientId = response['id'];

          Get.defaultDialog(
            title: "Check-In",
            middleText: "Do you want to check in for this client?",
            textConfirm: "Yes",
            textCancel: "No",
            confirmTextColor: Colors.white,
            onConfirm: () {
              Get.back(); // Close dialog

              // Enable the global flag for newly created clients
              ClientController clientController = Get.find<ClientController>();
              clientController.newlyCreatedClientCheckedIn.value = true;

              Get.toNamed('/client-qr-code-scan',
                  arguments: {"clientId": newClientId, "redirected": true});
            },
            onCancel: () {
              Get.back(); // Close the dialog first
              Future.delayed(Duration(milliseconds: 300), () {
                Get.offAllNamed('/dashboard'); // Ensure full navigation reset
              });
            },
          );
        } else {
          // API returned an error, show the error message in a toast
          Fluttertoast.showToast(
            msg: "Error: ${response['error']}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        // Handle the error if something goes wrong with the API request
        Fluttertoast.showToast(
          msg: "Failed to create client. Please try again.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getLocationAreas();
  }

  //******************************************************************UI Rendering

  // This function renders the app bar
  AppBar renderAppBar() {
    return AppBar(
      backgroundColor: kMainColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: const Icon(Icons.arrow_back, color: Colors.white)
          .onTap(() => Get.toNamed("/dashboard")),
      title: Text("Create New Client", style: TextStyle(color: Colors.white)),
      centerTitle: true,
    );
  }

  //The function renders the first name field
  Widget renderFirstNameField() {
    return TextFormField(
      controller: firstNameController,
      decoration: const InputDecoration(
        labelText: "First Name",
        hintText: "Enter first name",
        border: OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? 'First Name is required' : null,
    );
  }

  //The function renders the last name field
  Widget renderLastNameField() {
    return TextFormField(
      controller: lastNameController,
      decoration: const InputDecoration(
        labelText: "Last Name",
        hintText: "Enter last name",
        border: OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? 'Last Name is required' : null,
    );
  }

  //The function renders the phone number field
  Widget renderPhoneNumberField() {
    return TextFormField(
      controller: phoneNumberController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Phone Number",
        hintText: "Enter phone number",
        border: OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? 'Phone Number is required' : null,
    );
  }

  //The function renders the address field
  Widget renderAddressField() {
    return TextFormField(
      controller: addressController,
      decoration: const InputDecoration(
        labelText: "Address",
        hintText: "Enter address",
        border: OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? 'Address is required' : null,
    );
  }

  //The function renders the company name field
  Widget renderCompanyNameField() {
    return TextFormField(
      controller: companyNameController,
      decoration: const InputDecoration(
        labelText: "Company Name",
        hintText: "Enter company name",
        border: OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? 'Company Name is required' : null,
    );
  }

  //The function renders the commercial register field
  Widget renderCommercialRegisterField() {
    return TextFormField(
      controller: commercialRegisterController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Commercial Register",
        hintText: "Enter commercial register",
        border: OutlineInputBorder(),
      ),
      validator: (value) =>
          value!.isEmpty ? 'Commercial Register is required' : null,
    );
  }

  //The function renders the mof number field
  Widget renderMofNumberField() {
    return TextFormField(
      controller: mofNumberController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "MOF Number",
        hintText: "Enter MOF number",
        border: OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? 'MOF Number is required' : null,
    );
  }

  //The function renders the VAT Register Field
  Widget renderVatRegisterField() {
    return TextFormField(
      controller: vatRegisterController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "VAT Register",
        hintText: "Enter VAT register",
        border: OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? 'VAT Register is required' : null,
    );
  }

  //The function renders the location area field
  Widget renderLocationAreaField() {
    return DropdownButtonFormField<String>(
      value: selectedLocationArea,
      decoration: const InputDecoration(
        labelText: "Location Area",
        border: OutlineInputBorder(),
      ),
      items: locationAreas.map((area) {
        return DropdownMenuItem<String>(
          value: area['id'].toString(),
          child: Text(area['location_area_name']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedLocationArea = value!;
        });
      },
    );
  }

  //This function renders the izaa tijariyye file upload field
  Widget renderIzaaTijariyyeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Izaa Tijariye:"),
        Row(
          children: [
            Radio<FileTypeOption>(
              value: FileTypeOption.image,
              groupValue: _selectedFileTypeIzaa,
              onChanged: (FileTypeOption? value) {
                setState(() {
                  _selectedFileTypeIzaa = value!;
                });
              },
            ),
            const Text('Image'),
            const SizedBox(width: 20),
            Radio<FileTypeOption>(
              value: FileTypeOption.document,
              groupValue: _selectedFileTypeIzaa,
              onChanged: (FileTypeOption? value) {
                setState(() {
                  _selectedFileTypeIzaa = value!;
                });
              },
            ),
            const Text('Document'),
          ],
        ),
        ElevatedButton(
          onPressed: selectFileForIzaaTijariyePdf,
          child: Text(izaaTijariyePdf == null
              ? "Select Izaa Tijariye File"
              : "File Selected"),
        ),
        if (izaaTijariyePdf != null) ...[
          _selectedFileTypeIzaa == FileTypeOption.image
              ? Image.file(izaaTijariyePdf!, height: 50, width: 50)
              : Text(izaaTijariyePdf!.path.split('/').last),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteFileIzaa,
          ),
        ]
      ],
    );
  }

  //This function renders the photocopie of id file upload field
  Widget renderPhotocopieOfIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Photocopy ID Card:"),
        Row(
          children: [
            Radio<FileTypeOption>(
              value: FileTypeOption.image,
              groupValue: _selectedFileTypePhotocopy,
              onChanged: (FileTypeOption? value) {
                setState(() {
                  _selectedFileTypePhotocopy = value!;
                });
              },
            ),
            const Text('Image'),
            const SizedBox(width: 20),
            Radio<FileTypeOption>(
              value: FileTypeOption.document,
              groupValue: _selectedFileTypePhotocopy,
              onChanged: (FileTypeOption? value) {
                setState(() {
                  _selectedFileTypePhotocopy = value!;
                });
              },
            ),
            const Text('Document'),
          ],
        ),
        ElevatedButton(
          onPressed: selectFileForPhotocopyIdCardPdf,
          child: Text(photocopyIdCardPdf == null
              ? "Select Photocopy ID Card File"
              : "File Selected"),
        ),
        if (photocopyIdCardPdf != null) ...[
          _selectedFileTypePhotocopy == FileTypeOption.image
              ? Image.file(photocopyIdCardPdf!, height: 50, width: 50)
              : Text(photocopyIdCardPdf!.path.split('/').last),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteFilePhotocopy,
          ),
        ]
      ],
    );
  }

  //This function renders the create new client button
  Widget renderCreateNewClientButton() {
    return ButtonGlobal(
      buttontext: "Create Client",
      buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
      onPressed: createClient,
      iconWidget: null,
      iconColor: Colors.white,
    );
  }

  Future<void> deleteFileIzaa() async {
    setState(() {
      izaaTijariyePdf = null;
    });
  }

  Future<void> deleteFilePhotocopy() async {
    setState(() {
      photocopyIdCardPdf = null;
    });
  }

  Widget renderFilePreviewIzaa() {
    if (izaaTijariyePdf != null) {
      return Row(
        children: [
          isImageFileIzaa
              ? Image.file(izaaTijariyePdf!, height: 50, width: 50)
              : Text(izaaTijariyePdf!.path.split('/').last),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: deleteFileIzaa,
          ),
        ],
      );
    }
    return SizedBox.shrink();
  }

  Widget renderFilePreviewPhotocopy() {
    if (photocopyIdCardPdf != null) {
      return Row(
        children: [
          isImageFilePhotocopy
              ? Image.file(photocopyIdCardPdf!, height: 50, width: 50)
              : Text(photocopyIdCardPdf!.path.split('/').last),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: deleteFilePhotocopy,
          ),
        ],
      );
    }
    return SizedBox.shrink();
  }

  // The function renders the client price class dropdown
  Widget renderClientPriceClassDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedPriceClass ?? "None", // Default to "None"
      decoration: const InputDecoration(
        labelText: "Client Price Class",
        border: OutlineInputBorder(),
      ),
      items: priceClasses.map((priceClass) {
        return DropdownMenuItem<String>(
          value: priceClass,
          child: Text(priceClass),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedPriceClass =
              value == "None" ? null : value; // Set null if "None" is selected
        });
      },
      isExpanded: true,
      hint: const Text("Select Price Class"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kMainColor,
        appBar: renderAppBar(),
        body: Container(
          alignment: Alignment.topCenter,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              topLeft: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    // First Name Field
                    renderFirstNameField(),
                    const SizedBox(height: 20),

                    // Last Name Field
                    renderLastNameField(),
                    const SizedBox(height: 20),

                    // Phone Number Field
                    renderPhoneNumberField(),
                    const SizedBox(height: 20),

                    // Address Field
                    renderAddressField(),
                    const SizedBox(height: 20),

                    // Company Name Field
                    renderCompanyNameField(),
                    const SizedBox(height: 20),

                    // Commercial Register Field
                    renderCommercialRegisterField(),
                    const SizedBox(height: 20),

                    // MOF Number Field
                    renderMofNumberField(),
                    const SizedBox(height: 20),

                    // VAT Register Field
                    renderVatRegisterField(),
                    const SizedBox(height: 20),

                    // Location Area Dropdown
                    renderLocationAreaField(),
                    const SizedBox(height: 20),

                    // Client Price Class Dropdown
                    renderClientPriceClassDropdown(),
                    const SizedBox(height: 20),

                    // File Type Selection for Izaa
                    renderIzaaTijariyyeField(),
                    const SizedBox(height: 20),

                    // File Type Selection for Photocopy
                    renderPhotocopieOfIdField(),
                    const SizedBox(height: 20),

                    // Create Client Button
                    renderCreateNewClientButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
