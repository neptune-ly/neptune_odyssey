{{-- <x-neptune::skeleton variant="text" :lines="3" /> — variant: text|circle|rect --}}
@props(['variant' => null, 'width' => null, 'height' => null, 'lines' => null])

<npt-skeleton
    @if($variant) variant="{{ $variant }}" @endif
    @if($width) width="{{ $width }}" @endif
    @if($height) height="{{ $height }}" @endif
    @if($lines) lines="{{ $lines }}" @endif
    {{ $attributes }}
></npt-skeleton>
