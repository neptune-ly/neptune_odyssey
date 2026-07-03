{{--
    <x-neptune::alert tone="warning" title="Heads up" dismissible>
        Your session will expire in 5 minutes.
    </x-neptune::alert>
    tone: info (default) | success | warning | error
--}}
@props(['tone' => null, 'title' => null, 'dismissible' => false])

<npt-alert
    @if($tone) tone="{{ $tone }}" @endif
    @if($title) title="{{ $title }}" @endif
    @if($dismissible) dismissible @endif
    {{ $attributes }}
>{{ $slot }}</npt-alert>
