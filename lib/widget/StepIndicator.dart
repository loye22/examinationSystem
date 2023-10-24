import 'package:flutter/material.dart';

class StepIndicator extends StatefulWidget {
  final int currentStep;
  final int totalSteps;

  StepIndicator({required this.currentStep, required this.totalSteps});

  @override
  State<StepIndicator> createState() => _StepIndicatorState();
}

class _StepIndicatorState extends State<StepIndicator> {

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        widget.totalSteps,
            (index) => _buildStepNode(index + 1),
      ),
    );
  }
  List<String> lable = ['Basic information' , 'Select questions' , 'Add settings' , 'Finish'];
  Widget _buildStepNode(int step) {
    final isActive = step == widget.currentStep;
    final isCompleted = step < widget.currentStep;
    final isLastStep = step == widget.totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: <Widget>[
            Container(
              width: 50.0,
              height: 70.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.blue : Colors.grey,
              ),
              child: Center(
                child: isActive
                    ? Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20.0,
                )
                    : Text(
                  step.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!isLastStep)
              Container(
                width: 300.0,
                height: 2.0,
                color: isCompleted ? Colors.blue : Colors.grey,
              ),
          ],
        ),
        Text(lable[step - 1 ])
      ],
    );
  }
}



