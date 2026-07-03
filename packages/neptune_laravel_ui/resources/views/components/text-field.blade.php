{{-- <x-neptune::text-field label="IBAN" placeholder="LY.." :error="$errors->first('iban')" /> --}}
@props(['label' => null, 'value' => null, 'placeholder' => null, 'error' => null, 'type' => null])

<npt-text-field
    @if($label) label="{{ $label }}" @endif
    @if(!is_null($value)) value="{{ $value }}" @endif
    @if($placeholder) placeholder="{{ $placeholder }}" @endif
    @if($error) error="{{ $error }}" @endif
    @if($type) type="{{ $type }}" @endif
    {{ $attributes }}
></npt-text-field>
