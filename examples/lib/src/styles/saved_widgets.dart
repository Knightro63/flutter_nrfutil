import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:css/css.dart' as lsi;


class LSIFloatingActionButton extends StatelessWidget{
  LSIFloatingActionButton({
    GlobalKey? key,
    required this.allowed,
    this.onTap,
    required this.color,
    required this.icon,
    this.size = 60,
    this.iconSize = 35,
    this.offset = const Offset(20,20),
    this.margin = const EdgeInsets.only(bottom: 50, right: 20),
    this.iconColor = Colors.white,
    this.onHoverEnter,
    this.onHoverExit,
    this.alignment = Alignment.bottomRight
  }):super(key: key){
    if(alignment == Alignment.bottomRight){
      bottom = offset.dy;
      right = offset.dx;
    }
    else if(alignment == Alignment.bottomLeft){
      bottom = offset.dy;
      left = offset.dx;
    }
    else if(alignment == Alignment.topRight){
      top = offset.dy;
      right = offset.dx;
    }
    else if(alignment == Alignment.topLeft){
      top = offset.dy;
      left = offset.dx;
    }
  }

  late final double? left,top,right,bottom;
  final bool allowed;
  final Function()? onTap;
  final Color color;
  final IconData icon;
  final double size;
  final double iconSize;
  final Offset offset;
  final EdgeInsets margin;
  final Color iconColor;
  final Function(PointerEvent)? onHoverEnter;
  final Function(PointerEvent)? onHoverExit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return (allowed)?Positioned(
      key: key,
      left: left,
      top: top,
      bottom: bottom,
      right: right,
      child: MouseRegion(
        onEnter: onHoverEnter,
        onExit: onHoverExit,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(size/2)),
              boxShadow: [BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 10,
                offset: const Offset(0,2),
              ),]
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: iconSize,
            ),
          )
        )
      )
    ):Container();
  }
}

class InfoCard extends StatelessWidget{
  const InfoCard({
    Key? key,
    required this.color, 
    this.title = '', 
    this.subtitle = '', 
    this.infoTitle = '', 
    this.infoData = '', 
    this.image, 
    this.preInfo, 
    this.onTap,
    this.height,
    this.width = 650,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.showIcon = true,
    this.margin = const EdgeInsets.fromLTRB(0,0,0,0),
    this.padding,
    this.showBottomInfo = true,
    this.mouseCursor
  }):super(key: key);

  final Color color;
  final String title;
  final String subtitle; 
  final String infoTitle; 
  final String infoData;
  final String? image; 
  final Widget? preInfo;
  final Function()? onTap;
  final double? height;
  final double width;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool showIcon;
  final EdgeInsets margin;
  final EdgeInsets? padding;
  final bool showBottomInfo;
  final MouseCursor? mouseCursor;

  @override
  Widget build(BuildContext context){
    return InkWell(
      mouseCursor: mouseCursor,
      onTap: onTap,
      hoverColor: Colors.transparent,
      child: Container(
        margin: margin,
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 5,
            offset: const Offset(0,2),
          ),]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Padding(padding: const EdgeInsets.only(top:10, left: 10),
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontFamily: 'MuseoSans',
                  package: 'css',
                  decoration: TextDecoration.none
                )
              ),
            ),
            Container(
              //height: height-40,
              width: width,
              //alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom:10),
              padding: padding,
              color: Theme.of(context).splashColor,
              child:
              Column(
                mainAxisAlignment: mainAxisAlignment,
                crossAxisAlignment: crossAxisAlignment,
                children: [
                (preInfo!=null)?preInfo!:Container(),
                (showBottomInfo)?Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[
                  (image != null)?
                  Padding(
                  padding: const EdgeInsets.only(left:30),
                  child: Row(
                    children:[
                      SizedBox(
                        width: 50,
                        height: 40,
                        // child: 
                        // SvgPicture.asset(
                        //   image!,
                        //   fit: BoxFit.cover,
                        // ),
                      ),
                      Text(
                        ' $subtitle',
                        style: TextStyle(
                          color: color,
                          fontSize: 24,
                          fontFamily: 'Klavika Bold',
                          package: 'css',
                          decoration: TextDecoration.none
                        )
                      )
                    ])
                  )
                  :Padding(
                    padding: const EdgeInsets.only(left:30),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: color,
                        fontSize: 24,
                        fontFamily: 'Klavika Bold',
                        package: 'css',
                        decoration: TextDecoration.none
                      )
                    )
                  ),
                  Row(
                    children:[
                    (infoData != '')?Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Text(
                        infoTitle,
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontFamily: 'Klavika',
                          package: 'css',
                          decoration: TextDecoration.none
                        )
                      ),
                      Text(
                        infoData,
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontFamily: 'Klavika',
                          package: 'css',
                          decoration: TextDecoration.none
                        )
                      ),
                    ],):const SizedBox(height: 0,),
                    (showIcon)?const Icon(
                      Icons.keyboard_arrow_right,
                      color: Color(0xffbbbbbb),
                      size: 36,
                    ):const SizedBox(height: 0,)
                  ])
                ]):const SizedBox(height: 0,)
            ],)
            )
        ]),
      )
    );
  }
}

class EnterTextFormField extends StatelessWidget{
  const EnterTextFormField({
    Key? key,
    this.maxLines,
    this.minLines,
    this.label, 
    required this.controller,
    this.focusNode,
    this.onTap,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.width,
    this.height,
    this.color,
    this.textStyle,
    this.margin = const EdgeInsets.fromLTRB(10, 0, 10, 0),
    this.readOnly = false,
    this.keyboardType = TextInputType.multiline,
    this.padding = const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
    this.inputFormatters,
    this.radius = 10.0
  }):super(key: key);
  
  final int? minLines;
  final int? maxLines;
  final String? label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Function()? onTap;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final Function()? onEditingComplete;
  final double? width;
  final double? height;
  final Color? color;
  final bool readOnly;
  final EdgeInsets margin;
  final TextInputType keyboardType;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final List<TextInputFormatter>? inputFormatters;
  final double radius;

  @override
  Widget build(BuildContext context){
    return Container(
      margin: margin,
      width: width,
      height: height,
      alignment: Alignment.center,
      child: TextField(
        //textAlign: TextAlign.,
        readOnly: readOnly,
        keyboardType: keyboardType,
        minLines: minLines,
        maxLines: maxLines,
        autofocus: false,
        focusNode: focusNode,
        //textAlignVertical: TextAlignVertical.center,
        onTap: onTap,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onEditingComplete:onEditingComplete,
        inputFormatters: inputFormatters,
        controller: controller,
        style: (textStyle == null)?Theme.of(context).primaryTextTheme.bodyMedium:textStyle,
        decoration: InputDecoration(
          isDense: true,
          //labelText: label,
          filled: true,
          fillColor: (color == null)?Theme.of(context).splashColor:color,
          contentPadding: padding,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(radius),
            ),
            borderSide: const BorderSide(
                width: 0, 
                style: BorderStyle.none,
            ),
          ),
          hintStyle: Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(color: Colors.grey),
          hintText: label
        ),
      )
    );
  }
}

class LSILoadingWheel extends StatelessWidget{
  const LSILoadingWheel({
    Key? key,
    this.color,
    this.indicatorColor,
    required this.size
  }):super(key: key);
  final Size size;
  final Color? color;
  final Color? indicatorColor;

  @override
  Widget build(BuildContext context){
    return Container(
      width: size.width,
      height: size.height,
      color: color ?? Theme.of(context).canvasColor,
      alignment: Alignment.center,
      child: CircularProgressIndicator(color: indicatorColor)
    );
  }
}

class LSIWidgets{
  static Widget dropDown({
    Key? key,
    required List<DropdownMenuItem<dynamic>> itemVal, 
    TextStyle style = const TextStyle(
      color: lsi.darkGrey,
      fontFamily: 'Klavika',
      package: 'css',
      fontSize: 14
    ),
    required dynamic value,
    Function(dynamic)? onchange,
    double width = 80,
    double height = 36,
    EdgeInsets padding = const EdgeInsets.only(left:10),
    EdgeInsets margin = const EdgeInsets.fromLTRB(0, 5, 0, 5),
    Color color = Colors.transparent,
    double radius = 0,
    Alignment alignment = Alignment.center,
    Border? border,
  }){
    return Container(
      key: key,
      margin: margin,
      alignment: alignment,
      width: width,
      height:height,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        border: border
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton <dynamic>(
          dropdownColor: color,
          isExpanded: true,
          items: itemVal,
          value: value,//ddInfo[i],
          isDense: true,
          focusColor: lsi.lightBlue,
          style: style,
          onChanged: onchange,
        ),
      ),
    );
  }

  static Widget saveButton({
    required String text, 
    Function()? onTap,
    double width = 100,
    double? maxWidth
  }){
    if(maxWidth != null){
      if(width > maxWidth){
        width = maxWidth;
      }
    }

    return InkWell(
      onTap:onTap,
      child: Container(
        height: 60,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: (text == 'cancel')?Colors.transparent:lsi.lightGrey,
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          border: Border.all(width:5,color: (text == 'cancel')?Colors.white:lsi.lightGrey)
        ),
        child:Text(
          text.toUpperCase(),
          style: TextStyle(
            color: (text == 'cancel')?Colors.white:lsi.chartGrey,
            fontFamily: 'Klavika Bold',
            package: 'css',
            fontSize: 20,
            decoration: TextDecoration.none
          ),
        ),
      )
    );
  }

  static Widget squareButton({
    Key? key,
    bool iconFront = false,
    Widget? icon,
    required Color buttonColor,
    Color textColor = lsi.darkGrey,
    required String text,
    Function()? onTap,
    String fontFamily = 'Klavika Bold',
    double fontSize = 18.0,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    double height = 75,
    double width = 100,
    double radius = 5,
    Alignment? alignment,
    EdgeInsets? margin,
    EdgeInsets? padding,
    List<BoxShadow>? boxShadow,
    Color? borderColor,
    bool loading = false,
    Function(PointerEnterEvent)? onHoverEnter,
    Function(PointerExitEvent)? onHoverExit,
  }){
    Widget totalIcon = (icon != null)?icon:Container();
    return MouseRegion(
      onEnter: onHoverEnter,
      onExit: onHoverExit,
      child: InkWell(
        onTap: onTap,
        child:Container(
          alignment: alignment,//Alignment.center,
          height: height,//75,
          width: width,//deviceWidth,
          margin: margin,//EdgeInsets.fromLTRB(10,5,10,5),
          padding: padding,//EdgeInsets.fromLTRB(25,0,10,0),
          decoration: BoxDecoration(
            color: buttonColor,
            border: Border.all(
              color: (borderColor == null)?buttonColor:borderColor,
              width: 2
            ),
            borderRadius: BorderRadius.all(Radius.circular(radius)),
            boxShadow: boxShadow
          ),
          child:loading?LSILoadingWheel(
            color: buttonColor,
            indicatorColor: textColor,
            size: Size(width,height),
          ):Row(
            key: key,
            mainAxisAlignment: mainAxisAlignment,//MainAxisAlignment.spaceBetween,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (iconFront)?totalIcon:Container(),
              Text(
                text.toUpperCase(),
                
                textAlign: TextAlign.start,
                style:TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontFamily: fontFamily,
                  decoration: TextDecoration.none,
                  package: 'css'
                )
              ),
              (!iconFront)?totalIcon:Container(),
          ],)
        )
      )
    );
  }
  
  static Widget iconName({
    required IconData icon,
    Function()? onTap,
    required Color color
  }){
    return 
    InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left:10,right:10),
        child:Stack(
          children:[
            Icon(
              icon,
              color: color,
              size: 36,
            ),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              //color: (hasNewNot && name == "NOTIFICATIONS")?Color(0xffe85454):Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(12/2)),
            ),
          ),
        ])
      )
    );
  }

  static Widget dropDownItems({
    Function()? onTap, 
    Function(PointerHoverEvent event)? onHover,
    required BoxDecoration decoration, 
    required Text text, 
    EdgeInsets? margin,
  }){
    return InkWell(
      onTap: onTap,
      child: MouseRegion(
        onHover: onHover,
        child:Container(
          alignment: Alignment.center,
          height: 40,
          margin: margin,
          decoration: decoration,
          child: text,
        )
      )
    );
  }
  static Widget iconNote(IconData icon, String text, TextStyle style, double size){
    return SizedBox(
      child: Row(children: [
        Icon(
          icon,
          size:size,
          color: style.color
        ),
        Text(
          ' $text',
          style: style,
        )
      ],),
    );
  }
}

class UploadImage extends StatelessWidget{
  const UploadImage({
    Key? key,
    this.label, 
    this.onTap,
    required this.imageController,
    this.color,
    required this.width,
    this.name =  "BROWSE",
    this.icon
  }):super(key: key);

  final String? label;
  final IconData? icon;
  final String name;
  final Function()? onTap;
  final TextEditingController imageController;
  final Color? color;
  final double? width;

  @override
  Widget build(BuildContext context){
    return Row(children: [
      Container(
        width: width,
        height: 35,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        decoration: BoxDecoration(
          color: (color != null)?color:Theme.of(context).indicatorColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(7),
            bottomLeft: Radius.circular(7)
          )
        ),
        child: Text(
          imageController.text != ''?imageController.text:label!,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: Theme.of(context).primaryTextTheme.bodyMedium!.fontFamily,
            fontSize: Theme.of(context).primaryTextTheme.bodyMedium!.fontSize,
            color: imageController.text != ''?Theme.of(context).primaryTextTheme.bodyMedium!.color:Colors.grey,
            decoration: TextDecoration.none
          ),
        ),
      ),
      InkWell(
        onTap: onTap,
        child: Container(
          height: 35,
          width: 80,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(left:2),
          decoration: BoxDecoration(
            color: (color != null)?color:Theme.of(context).indicatorColor,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(7),
              bottomRight: Radius.circular(7)
            )
          ),
          child: icon == null?Text(
            name,
            style: TextStyle(
              fontFamily: Theme.of(context).primaryTextTheme.bodyMedium!.fontFamily,
              fontSize: 16,
              color: Theme.of(context).primaryTextTheme.bodyMedium!.color!,
              decoration: TextDecoration.none
            ),
          ):Icon(icon,color: Theme.of(context).primaryTextTheme.bodyMedium!.color!,size: 20,),
        ),
      ),
    ],);
  }
}