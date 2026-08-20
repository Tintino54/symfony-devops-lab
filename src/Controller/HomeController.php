<?php

declare(strict_types=1);

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class HomeController extends AbstractController
{
    #[Route('/pouet', name: 'home')]
    public function index(): Response
    {
        return new Response('Hello from HomeController and automatic deployment!', Response::HTTP_OK, ['Content-Type' => 'text/plain']);
    }

    #[Route('/health', name: 'health')]
    public function health(): Response
    {
        return new Response('OK');
    }
}
