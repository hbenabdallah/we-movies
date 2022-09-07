<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

/**
 * @Route("/", name="app_we_movies_home", methods={"get"})
 */
class HomeController extends AbstractController
{
    public function __construct()
    {
    }

    public function __invoke(Request $request): Response
    {
        return $this->render('base.html.twig', []);
    }
}
