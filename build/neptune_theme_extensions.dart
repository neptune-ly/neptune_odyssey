// GENERATED — do not edit by hand.
// Neptune Odyssey ThemeExtensions: 'success' colour role (M3 addition) + per-brand
// corner family and type set. Read these instead of hard-coding any value.
import 'package:flutter/material.dart';

@immutable
class NeptuneColors extends ThemeExtension<NeptuneColors> {
  final Color success, onSuccess, successContainer, onSuccessContainer;
  const NeptuneColors({required this.success, required this.onSuccess, required this.successContainer, required this.onSuccessContainer});
  @override NeptuneColors copyWith({Color? success, Color? onSuccess, Color? successContainer, Color? onSuccessContainer}) =>
    NeptuneColors(success: success ?? this.success, onSuccess: onSuccess ?? this.onSuccess, successContainer: successContainer ?? this.successContainer, onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer);
  @override NeptuneColors lerp(ThemeExtension<NeptuneColors>? o, double t){
    if (o is! NeptuneColors) return this;
    return NeptuneColors(success: Color.lerp(success,o.success,t)!, onSuccess: Color.lerp(onSuccess,o.onSuccess,t)!, successContainer: Color.lerp(successContainer,o.successContainer,t)!, onSuccessContainer: Color.lerp(onSuccessContainer,o.onSuccessContainer,t)!);
  }
}

@immutable
class NeptuneShapes extends ThemeExtension<NeptuneShapes> {
  final double xs, sm, md, lg, xl, xxl;
  const NeptuneShapes({required this.xs, required this.sm, required this.md, required this.lg, required this.xl, required this.xxl});
  BorderRadius get rXs => BorderRadius.circular(xs);
  BorderRadius get rSm => BorderRadius.circular(sm);
  BorderRadius get rMd => BorderRadius.circular(md);
  BorderRadius get rLg => BorderRadius.circular(lg);
  BorderRadius get rXl => BorderRadius.circular(xl);
  BorderRadius get rXxl => BorderRadius.circular(xxl);
  @override NeptuneShapes copyWith({double? xs,double? sm,double? md,double? lg,double? xl,double? xxl}) =>
    NeptuneShapes(xs: xs ?? this.xs, sm: sm ?? this.sm, md: md ?? this.md, lg: lg ?? this.lg, xl: xl ?? this.xl, xxl: xxl ?? this.xxl);
  @override NeptuneShapes lerp(ThemeExtension<NeptuneShapes>? o, double t){
    if (o is! NeptuneShapes) return this;
    double l(double a,double b)=>a+(b-a)*t;
    return NeptuneShapes(xs:l(xs,o.xs),sm:l(sm,o.sm),md:l(md,o.md),lg:l(lg,o.lg),xl:l(xl,o.xl),xxl:l(xxl,o.xxl));
  }
}

class NeptuneType {
  final String display, text, num;
  const NeptuneType({required this.display, required this.text, required this.num});
}

// neptune
const NeptuneColors neptuneSuccessLight = NeptuneColors(success: Color(0xFF2E9052), onSuccess: Color(0xFFF2FFF5), successContainer: Color(0xFFBCECC8), onSuccessContainer: Color(0xFF003006));
const NeptuneColors neptuneSuccessDark = NeptuneColors(success: Color(0xFF79CE91), onSuccess: Color(0xFF002405), successContainer: Color(0xFF00461B), onSuccessContainer: Color(0xFFBCECC8));
const NeptuneShapes neptuneShapes = NeptuneShapes(xs: 8, sm: 12, md: 16, lg: 24, xl: 32, xxl: 44);
const NeptuneType neptuneType = NeptuneType(display: 'Hanken Grotesk', text: 'Hanken Grotesk', num: 'Hanken Grotesk');

// triton
const NeptuneColors tritonSuccessLight = NeptuneColors(success: Color(0xFF2D8949), onSuccess: Color(0xFFF3FFF5), successContainer: Color(0xFFBEECC6), onSuccessContainer: Color(0xFF003003));
const NeptuneColors tritonSuccessDark = NeptuneColors(success: Color(0xFF7CCD8E), onSuccess: Color(0xFF002403), successContainer: Color(0xFF004519), onSuccessContainer: Color(0xFFBEECC6));
const NeptuneShapes tritonShapes = NeptuneShapes(xs: 12, sm: 18, md: 26, lg: 34, xl: 44, xxl: 56);
const NeptuneType tritonType = NeptuneType(display: 'Bricolage Grotesque', text: 'Hanken Grotesk', num: 'Hanken Grotesk');

// nereid
const NeptuneColors nereidSuccessLight = NeptuneColors(success: Color(0xFF2E9052), onSuccess: Color(0xFFF2FFF5), successContainer: Color(0xFFBCECC8), onSuccessContainer: Color(0xFF003006));
const NeptuneColors nereidSuccessDark = NeptuneColors(success: Color(0xFF79CE91), onSuccess: Color(0xFF002405), successContainer: Color(0xFF00461B), onSuccessContainer: Color(0xFFBCECC8));
const NeptuneShapes nereidShapes = NeptuneShapes(xs: 4, sm: 8, md: 12, lg: 18, xl: 26, xxl: 36);
const NeptuneType nereidType = NeptuneType(display: 'Space Grotesk', text: 'Hanken Grotesk', num: 'Space Grotesk');

// proteus
const NeptuneColors proteusSuccessLight = NeptuneColors(success: Color(0xFF2E9052), onSuccess: Color(0xFFF2FFF5), successContainer: Color(0xFFBCECC8), onSuccessContainer: Color(0xFF003006));
const NeptuneColors proteusSuccessDark = NeptuneColors(success: Color(0xFF79CE91), onSuccess: Color(0xFF002405), successContainer: Color(0xFF00461B), onSuccessContainer: Color(0xFFBCECC8));
const NeptuneShapes proteusShapes = NeptuneShapes(xs: 6, sm: 10, md: 14, lg: 20, xl: 28, xxl: 38);
const NeptuneType proteusType = NeptuneType(display: 'Sora', text: 'Hanken Grotesk', num: 'Sora');

