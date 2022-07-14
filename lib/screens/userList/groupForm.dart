import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/constants/locale.dart';

class GroupForm extends StatefulWidget {
  final Function(String roomName) onRoomNameSubmitted;
  final VoidCallback close;
  const GroupForm(
      {Key? key, required this.onRoomNameSubmitted, required this.close})
      : super(key: key);

  @override
  State<GroupForm> createState() => _GroupFormState();
}

class _GroupFormState extends State<GroupForm> {
  String? _roomTitle;
  final _formKey = GlobalKey<FormState>();

  void _onSubmitData() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onRoomNameSubmitted(_roomTitle!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(Locale.roomName,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24)),
              Form(
                key: _formKey,
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return Locale.enterRoomName;
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    label: Text(Locale.roomName),
                  ),
                  onSaved: (value) => _roomTitle = value,
                  textInputAction: TextInputAction.done,
                ),
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: widget.close,
                      child: Text(
                        Locale.cancel,
                        style: TextStyle(color: Theme.of(context).errorColor),
                      )),
                  TextButton(
                      onPressed: _onSubmitData,
                      child: const Text(Locale.submit))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
